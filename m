Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 9972C6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 12:23:17 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so3822936qcs.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:23:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120407080027.GA2584@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
Date: Tue, 10 Apr 2012 11:23:16 -0500
Message-ID: <CAH2r5mvLVnM3Se5vBBsYzwaz5Ckp3i6SVnGp2T0XaGe9_u8YYA@mail.gmail.com>
Subject: Re: [Lsf] [RFC] writeback and cgroup
From: Steve French <smfrench@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Sat, Apr 7, 2012 at 3:00 AM, Jan Kara <jack@suse.cz> wrote:
> =A0Hi Vivek,
>
> On Wed 04-04-12 10:51:34, Vivek Goyal wrote:
>> On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
>> [..]
>> > IIUC, without cgroup, the current writeback code works more or less
>> > like this. =A0Throwing in cgroup doesn't really change the fundamental
>> > design. =A0Instead of a single pipe going down, we just have multiple
>> > pipes to the same device, each of which should be treated separately.
>> > Of course, a spinning disk can't be divided that easily and their
>> > performance characteristics will be inter-dependent, but the place to
>> > solve that problem is where the problem is, the block layer.
>>
>> How do you take care of thorottling IO to NFS case in this model? Curren=
t
>> throttling logic is tied to block device and in case of NFS, there is no
>> block device.
> =A0Yeah, for throttling NFS or other network filesystems we'd have to com=
e
> up with some throttling mechanism at some other level. The problem with
> throttling at higher levels is that you have to somehow extract informati=
on
> from lower levels about amount of work so I'm not completely certain now,
> where would be the right place. Possibly it also depends on the intended
> usecase - so far I don't know about any real user for this functionality.=
..

Remember to distinguish between the two ends of the network file system.
There are slightly different problems.   The client has to be able to
expose the number of requests (and size of writes, or equivalently
number of pages it can write at one time) so that writeback is not done
too aggressively.  File servers have to be able to
discover the i/o limits dynamically of the underlying volume (not the
block device, but potentially a pool of devices) so it can tell
the client how much i/o it can send.  For SMB2 server (Samba) and
eventually for NFS, how many simultaneous requests it
can support will allow them to sanely set the number of "credits"
on each response - ie tell the client how many requests
are allowed in flight to a particular export.

In the case of block device throttling - other than the file system
internally using such APIs who would use block device specific
throttling - only the file system knows where it wants to put hot data,
and in the case of btrfs, doesn't the file system manage the
storage pool.   The block device should be transparent to the
user in the long run, and only the volume visible.


--=20
Thanks,

Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
