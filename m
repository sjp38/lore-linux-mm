Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA20382
	for <linux-mm@kvack.org>; Sun, 13 Oct 2002 15:57:22 -0700 (PDT)
Message-ID: <3DA9FA51.2E4129E8@digeo.com>
Date: Sun, 13 Oct 2002 15:57:21 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.42-mm2 hangs system
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Henrik =?iso-8859-1?Q?St=F8rner?= <henrik@hswn.dk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Henrik Storner wrote:
> 
> I captured the ALT+ScrollLock output also:
> 
> Pid 1739, comm: nfsd
> EIP 0060:c0160250   CPU:0
> EIP is at d_lookup+0x70/0x160
>    Eflags: 00000297     Not tainted
> Call Trace
>    cached_lookup+0x1b/0x70
>    lookup_hash+0x72/0xe0
>    lookup_one_len+0x5f/0x70
>    find_exported_dentry+0x61f/0x730
>    reiserfs_delete_solid_item+0xfd/0x2b0
>    reiserfs_delete_solid_item+0xfd/0x2b0
>    check_journal_end+0x18a/0x2b0
>    rcu_check_callbacks+0x59/0x90
>    schedule_tick+0x348/0x350
>    update_process_times+0x46/0x60
>    reiserfs_decode_fh+0xc2/0x100
>    nfsd_acceptable+0x0/0xe0
>    fh_verify+0x38e/0x570
>    nfsd_acceptable+0x0/0xe0
>    nsfd_statfs+0x2f/0x70
>    nfsd3_proc_fsstat+0x37/0xc0
>    nfs3svc_decode_fhandle+0x38/0xb0

OK.  This is possibly dentry hashtable corruption.  I saw one
instance of this in about 2.5.41-mm3, followed by two other
weird random memory corruptions.

So it could be that something in there is going for a memory
stomp.  Don't really know any more than that at this time.

I _was_ suspecting oprofile or the latest addition to the shared
pagetable code.  But you're not using either.

It would be interesting to enable all the memory debugging options
under the kernel hacking menu, see if that turns anything up.

I'll build a kernel with your config and beat on reiserfs for a bit,
see if I can make it happen.

Apart from that, one way to isolate it is to just keep backing off
the patches until it goes away.  Which is not a ton of fun.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
