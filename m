Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8312B6B0033
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 04:53:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so11950201wmd.1
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 01:53:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r14si3542879wme.94.2017.10.15.01.53.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 15 Oct 2017 01:53:23 -0700 (PDT)
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
 <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard> <20171009183129.GE11645@wotan.suse.de>
 <87wp442lgm.fsf@xmission.com>
From: Aleksa Sarai <asarai@suse.de>
Message-ID: <8729041d-05e5-6bea-98db-7f265edde193@suse.de>
Date: Sun, 15 Oct 2017 19:53:11 +1100
MIME-Version: 1.0
In-Reply-To: <87wp442lgm.fsf@xmission.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

[Dammit, I thought I sent this earlier -- it looks like Thunderbird 
swallowed my original draft for this email.]

Hi Eric,

This is the bug that I talked to you about at LPC, related to 
devicemapper and it not being possible to issue DELETE and REMOVE 
operations on a devicemapper device that is still mounted in 
$some_namespace. [Before we go on, deferred removal and deletion can 
help here, but the deferral will never kick in until the reference goes 
away. On SUSE systems, deferred removal doesn't appear to work at all, 
but that's an issue for us to solve.]

> *Scratches my head*
> 
> That most definitely is not a leak.  It is a creation of a duplicate set
> of mounts.

Sorry for my sloppy wording, "leak" in this context means (for me at 
least) that the mount has been duplicated into a mount namespace due to 
sloppiness or malice by userspace.

> It is true that unmount in the parent will not remove those duplicate
> mounts in the other mount namespaces.  Unlink of the mountpoint will
> ensure that nothing is mounted on a file or directory in any mount
> namespace.
> 
> Given that they are duplicate of the mount they will not make any umount
> fail in the original namespace.

The error is a bit confusing. If you read the code, it turns out that 
"unmount failed" doesn't actually mean that umount(2) returned EBUSY. It 
means that the umount(2) *succeeded* and then the subsequent cleanup by 
Docker (where it tries to remove and delete unused devicemapper devices) 
fails. This is caused by the mount still existing in a container's mount 
namespace, due either a race condition (that I may have patch to fix[1]) 
or due to the container inadvertently bind-mounting the rootfs mounts 
from the host (I've seen people do ridiculous things like a recursive 
bind-mount of '/' into a container, for example).

> Further mount namespaces reference counts are held open by processes
> directly or file descriptors or other mount namespaces which are held
> open by processes.  So killing the appropriate set of processes should
> make the mount namespace go away.
> 
> I have heard tell of cases where mounts make it into mount namespaces
> where no one was expecting them to exist, and no one wanting to kill the
> processes using those mount namespaces.  But that is mostly sloppiness.
> That is not a big bad leak that can not be prevented, it is an "oops did
> I put that there?" kind of situation.
> 
> If there is something special about device mapper that needs to be take
> into account I would love to hear about it.

You're right that most of this issue (in the case of Docker) is just 
sloppiness, though the architecture makes it quite hard to resolve this 
issue at the moment. But the problem in Docker /can/ be solved at least 
partially by just removing the mountpoint. In fact I have a patch to do 
that already[2].

However, there is a more fundamental issue here, one which is quite 
concerning. It basically boils down to the fact that any unprivileged 
user can create a reference to a devicemapper mount on the host in such 
a way that the host won't know about it. A toy example is the following:

   % unshare -rm
   # mount --make-rprivate
   # mount -t tmpfs tmpfs /tmp && mkdir /tmp/saved_mount
   # mount --rbind /some/devicemapper/mount /tmp/saved_mount

At this point, even if the host does an `rm /some/devicemapper/mount`, 
the devicemapper reference will stick around in the "container". This 
isn't an issue for most cases, but with devicemapper, the host might 
want to do more management operations than just ` rm 
/some/devicemapper/mount`. They probably (like Docker does) want to 
remove the device and/or delete the device. In the above situation, they 
would be blocked from doing so. As I mention above, deferred deletion 
and removal can help here (the operation succeeds on non-SUSE systems) 
but there is still an issue that the space will not be reclaimed because 
the deferred operation will never kick off (because there is still a 
reference lying around).

As you've said, 8ed936b5671b ("vfs: Lazily remove mounts on unlinked 
files and directories.") added the ability to reduce possible DoS 
attacks against rmdir(2) by forcing unmounts in all mount namespaces 
that would block the removal from working. I'm wondering whether there 
would be interest in doing something similar for devicemapper's DELETE 
and REMOVE operations? From my perspective, it is quite hard for 
userspace to be able to resolve this issue. You mentioned that

 > killing the appropriate set of processes should
 > make the mount namespace go away.

But I'm not sure I understand how userspace can tell what "the 
appropriate set of processes" is. Not to mention that the appropriate 
set of processes could be an "innocent" process inside a container that 
accidentally inherited the mount, and then a malicious process 
duplicated the mount further -- making it hard to remove by the host.

[1]: https://github.com/opencontainers/runc/pull/1500
[2]: https://github.com/docker/docker/pull/34573

-- 
Aleksa Sarai
Snr. Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
