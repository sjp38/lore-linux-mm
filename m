Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 156CB6B0253
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 21:00:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y10so168204wmd.4
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:00:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j62si5875634wmd.114.2017.10.16.18.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 18:00:00 -0700 (PDT)
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
 <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard> <20171009183129.GE11645@wotan.suse.de>
 <87wp442lgm.fsf@xmission.com> <8729041d-05e5-6bea-98db-7f265edde193@suse.de>
 <20171015130625.o5k6tk5uflm3rx65@thunk.org> <87efq4qcry.fsf@xmission.com>
 <20171016011301.dcam44qylno7rm6a@thunk.org>
From: Aleksa Sarai <asarai@suse.de>
Message-ID: <c5bb6c1b-90c9-f50e-7283-af7e0de67caa@suse.de>
Date: Tue, 17 Oct 2017 11:59:50 +1100
MIME-Version: 1.0
In-Reply-To: <20171016011301.dcam44qylno7rm6a@thunk.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Dave Chinner <david@fromorbit.com>, =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

>> Looking at the code it appears ext4, f2fs, and xfs shutdown path
>> implements revoking a bdev from a filesystem.  Further if the ext4
>> implementation is anything to go by it looks like something we could
>> generalize into the vfs.
> 
> There are two things which the current file system shutdown paths do.
> The first is that they prevent the file system from attempting to
> write to the bdev.  That's all very file system specific, and can't be
> generalized into the VFS.
> 
> The second thing they do is they cause system calls which might modify
> the file system to return an error.  Currently operations that might
> result in _reads_ are not shutdown, so it's not a true revoke(2)
> functionality ala *BSD.  I assume that's what you are talking about
> generalizing into the VFS.  Personally, I would prefer to see us
> generalize something like vhangup() but which works on a file
> descriptor, not just a TTY.  That it is, it disconnects the file
> descriptor entirely from the hardware / file system so in the case of
> the tty, it can be used by other login session, and in the case of the
> file descriptor belonging to a file system, it stops the file system
> from being unmounted
Presumably the fd would just be used to specify the backing store? I was 
imagining doing it through an additional umount(2) flag but I guess that 
having an fd open is probably better form.

I'm a little confused about whether this actually will solve the 
original problem though, because it still requires the iteration over 
/proc/**/mounts in order for userspace to finish the unmounts. I feel 
like this is trying to generalise the idea behind luksSuspend -- am I 
misunderstanding how this would solve the original issue? Is it the case 
that if we "disconnect" at the file descriptor level, then the bdev is 
no longer considered "used" and it can be operated on safely?

>> Ted, Aleksa would either of you be interested in generalizing what ext4,
>> f2fs, and xfs does now and working to put a good interface on it?  I can
>> help especially with review but for the short term I am rather booked.
> 
> Unfortunately, I have way too much travel coming up in the short term,
> so I probably won't have to take on a new project until at least
> mid-to-late-November at the earliest.  Aleska, do you have time?  I
> can consult on a design, but I have zero coding time for the next
> couple of weeks.

I can give it a shot, but a quick disclaimer that I'm not very familiar 
with the VFS codebase so the review cycle will probably take a while. Oh 
well, it's a good opportunity for me to learn more about it. :D

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
