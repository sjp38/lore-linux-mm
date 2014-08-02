Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABAB6B0078
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 21:50:34 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id f10so3047251yha.20
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:50:34 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id n70si23379438yhn.65.2014.08.01.18.50.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 18:50:33 -0700 (PDT)
Received: by mail-yk0-f176.google.com with SMTP id 19so2878403ykq.21
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:50:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140801212120.1ae0eb02@tlielax.poochiereds.net>
References: <53DA8443.407@candelatech.com> <20140801064217.01852788@notabene.brown>
 <53DAB307.2000206@candelatech.com> <20140801075053.2120cb33@notabene.brown> <20140801212120.1ae0eb02@tlielax.poochiereds.net>
From: Roger Heflin <rogerheflin@gmail.com>
Date: Fri, 1 Aug 2014 20:50:13 -0500
Message-ID: <CAAMCDeeRWTEXu_UTWJ_aC_6Pb3286ijZByeDpwKwAeMqGBAODQ@mail.gmail.com>
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NeilBrown <neilb@suse.de>, Ben Greear <greearb@candelatech.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, Kernel development list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Doesn't NFS have an intr flag to allow kill -9 to work?   Whenever I
have had that set it has appeared to work after about 30 seconds or
so...without that kill -9 does not work when the nfs server is
missing.



On Fri, Aug 1, 2014 at 8:21 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Fri, 1 Aug 2014 07:50:53 +1000
> NeilBrown <neilb@suse.de> wrote:
>
>> On Thu, 31 Jul 2014 14:20:07 -0700 Ben Greear <greearb@candelatech.com> wrote:
>>
>> > -----BEGIN PGP SIGNED MESSAGE-----
>> > Hash: SHA1
>> >
>> > On 07/31/2014 01:42 PM, NeilBrown wrote:
>> > > On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com> wrote:
>> > >
>> > >> So, this has been asked all over the interweb for years and years, but the best answer I can find is to reboot the system or create a fake NFS server
>> > >> somewhere with the same IP as the gone-away NFS server.
>> > >>
>> > >> The problem is:
>> > >>
>> > >> I have some mounts to an NFS server that no longer exists (crashed/powered down).
>> > >>
>> > >> I have some processes stuck trying to write to files open on these mounts.
>> > >>
>> > >> I want to kill the process and unmount.
>> > >>
>> > >> umount -l will make the mount go a way, sort of.  But process is still hung. umount -f complains: umount2:  Device or resource busy umount.nfs: /mnt/foo:
>> > >> device is busy
>> > >>
>> > >> kill -9 does not work on process.
>> > >
>> > > Kill -1 should work (since about 2.6.25 or so).
>> >
>> > That is -[ONE], right?  Assuming so, it did not work for me.
>>
>> No, it was "-9" .... sorry, I really shouldn't be let out without my proof
>> reader.
>>
>> However the 'stack' is sufficient to see what is going on.
>>
>> The problem is that it is blocked inside the "VM" well away from NFS and
>> there is no way for NFS to say "give up and go home".
>>
>> I'd suggest that is a bug.   I cannot see any justification for fsync to not
>> be killable.
>> It wouldn't be too hard to create a patch to make it so.
>> It would be a little harder to examine all call paths and create a
>> convincing case that the patch was safe.
>> It might be herculean task to convince others that it was the right thing
>> to do.... so let's start with that one.
>>
>> Hi Linux-mm and fs-devel people.  What do people think of making "fsync" and
>> variants "KILLABLE" ??
>>
>> I probably only need a little bit of encouragement to write a patch....
>>
>> Thanks,
>> NeilBrown
>>
>
>
> It would be good to fix this in some fashion once and for all, and the
> wait_on_page_writeback wait is a major source of pain for a lot of
> people.
>
> So to summarize...
>
> The problem in a nutshell is that Ben has some cached writes to the
> NFS server, but the server has gone away (presumably forever). The
> question is -- how do we communicate to the kernel that that server
> isn't coming back and that those dirty pages should be invalidated so
> that we can umount the filesystem?
>
> Allowing fsync/close to be killable sounds reasonable to me as at least
> a partial solution. Both close(2) and fsync(2) are allowed to return
> EINTR according to the POSIX spec. Allowing a kill -9 there seems
> like it should be fine, and maybe we ought to even consider letting it
> be susceptible to lesser signals.
>
> That still leaves some open questions though...
>
> Is that enough to fix it? You'd still have the dirty pages lingering
> around, right? Would a umount -f presumably work at that point?
>
>> >
>> > Kernel is 3.14.4+, with some of extra patches, but probably nothing that
>> > influences this particular behaviour.
>> >
>> > [root@lf1005-14010010 ~]# cat /proc/3805/stack
>> > [<ffffffff811371ba>] sleep_on_page+0x9/0xd
>> > [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78
>> > [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d
>> > [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77
>> > [<ffffffffa0f04734>] nfs_file_fsync+0x37/0x83 [nfs]
>> > [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b
>> > [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19
>> > [<ffffffffa0f05305>] nfs_file_flush+0x6b/0x6f [nfs]
>> > [<ffffffff81183e46>] filp_close+0x3f/0x71
>> > [<ffffffff8119c8ae>] __close_fd+0x80/0x98
>> > [<ffffffff81183de5>] SyS_close+0x1c/0x3e
>> > [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b
>> > [<ffffffffffffffff>] 0xffffffffffffffff
>> > [root@lf1005-14010010 ~]# kill -1 3805
>> > [root@lf1005-14010010 ~]# cat /proc/3805/stack
>> > [<ffffffff811371ba>] sleep_on_page+0x9/0xd
>> > [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78
>> > [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d
>> > [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77
>> > [<ffffffffa0f04734>] nfs_file_fsync+0x37/0x83 [nfs]
>> > [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b
>> > [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19
>> > [<ffffffffa0f05305>] nfs_file_flush+0x6b/0x6f [nfs]
>> > [<ffffffff81183e46>] filp_close+0x3f/0x71
>> > [<ffffffff8119c8ae>] __close_fd+0x80/0x98
>> > [<ffffffff81183de5>] SyS_close+0x1c/0x3e
>> > [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b
>> > [<ffffffffffffffff>] 0xffffffffffffffff
>> >
>> > Thanks,
>> > Ben
>> >
>> > > If it doesn't please report the kernel version and cat /proc/$PID/stack
>> > >
>> > > for some processes that cannot be killed.
>> > >
>> > > NeilBrown
>> > >
>> > >>
>> > >>
>> > >> Aside from bringing a fake NFS server back up on the same IP, is there any other way to get these mounts unmounted and the processes killed without
>> > >> rebooting?
>> > >>
>> > >> Thanks, Ben
>> > >>
>> > >
>> >
>> >
>> > - --
>> > Ben Greear <greearb@candelatech.com>
>> > Candela Technologies Inc  http://www.candelatech.com
>> >
>> > -----BEGIN PGP SIGNATURE-----
>> > Version: GnuPG v1.4.13 (GNU/Linux)
>> > Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
>> >
>> > iQEcBAEBAgAGBQJT2rLiAAoJELbHqkYeJT4OqPgH/0taKW6Be90c1mETZf9yeqZF
>> > YMLZk8XC2wloEd9nVz//mXREmiu18Hc+5p7Upd4Os21J2P4PBMGV6P/9DMxxehwH
>> > YX1HKha0EoAsbO5ILQhbLf83cRXAPEpvJPgYHrq6xjlKB8Q8OxxND37rY7kl19Zz
>> > sdAw6GiqHICF3Hq1ATa/jvixMluDnhER9Dln3wOdAGzmmuFYqpTsV4EwzbKKqInJ
>> > 6C15q+cq/9aYh6usN6z2qJhbHgqM9EWcPL6jOrCwX4PbC1XjKHekpFN0t9oKQClx
>> > qSPuweMQ7fP4IBd2Ke8L/QlyOVblAKSE7t+NdrjfzLmYPzyHTyfLABR/BI053to=
>> > =/9FJ
>> > -----END PGP SIGNATURE-----
>>
>
>
> --
> Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
