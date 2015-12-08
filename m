Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id A30556B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 19:01:07 -0500 (EST)
Received: by pfu207 with SMTP id 207so1885904pfu.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:01:07 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id a10si748314pat.195.2015.12.07.16.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 16:01:05 -0800 (PST)
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
 <562AA15E.3010403@deltatee.com>
 <CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
 <565F6A7A.4040302@deltatee.com>
 <CAPcyv4jjyzKgPMzdwms8xH-_RoKEGxRp1r4qxEcPYmPv7qStqw@mail.gmail.com>
 <566244CC.5080107@deltatee.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <56661DBA.5000302@deltatee.com>
Date: Mon, 7 Dec 2015 17:00:58 -0700
MIME-Version: 1.0
In-Reply-To: <566244CC.5080107@deltatee.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2 00/20] get_user_pages() for dax mappings
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Stephen Bates <Stephen.Bates@pmcs.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

Hi Dan,

I've done a bit of digging and here's some more information:

* The crash occurs in ext4_end_io_unwritten when it tries to dereference 
bh->b_assoc_map which is not necessarily NULL.

* That function is called by __dax_pmd_fault, as the argument 
complete_unwritten.

* Looking in __dax_pmd_fault, the bug occurs if we hit either of the 
first two 'goto fallback' lines. (In my case, it's hitting the first one.)

* After the fallback code, it goes back to 'out', then checks '&bh'
for the unwritten flag. But bh hasn't been initialized yet and, on my 
setup, the unwritten flag happens to be set. So, it then calls 
complete_unwritten with a garbage bh and crashes.

If I move the memset(&bh) up in the code, before the goto fallbacks can 
occur, I can fix the crash.  I don't know if this is really the best way 
to fix the problem though.

--

However, unfortunately, fixing the above just uncovered another issue. 
Now the MR de-registration seems to have completed but the task hangs 
when it's trying to munmap the memory. (Stack trace at the end of this 
email.)

It looks like the i_mmap_lock_write is hanging in unlink_file_vma. I'm 
not really sure how to go about debugging this lock issue. If you have 
any steps I can try to get you more information let me know. I'm also 
happy to re-test if you have any other changes you'd like me to try.

Thanks,

Logan


> [ 240.520522] INFO: task client:1997 blocked for more than 120 seconds.
> [ 240.520638] Tainted: G O 4.4.0-rc3+donard2.5+ #87
> [ 240.520741] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 240.520847] client D ffff88047fd14800 0 1997 1912 0x00000004
> [ 240.520856] ffff88026bc7b240 0000000000000000 ffff88026bd38000 ffff88026bd37d30
> [ 240.520861] fffffffeffffffff ffff88026bc7b240 00007f4297513000 ffff880473aba240
> [ 240.520866] ffffffff81422896 ffff880470b34e40 ffffffff814242f1 ffff880476deddc0
> [ 240.520871] Call Trace:
> [ 240.520886] [<ffffffff81422896>] ? schedule+0x6c/0x79
> [ 240.520893] [<ffffffff814242f1>] ? rwsem_down_write_failed+0x285/0x2cb
> [ 240.520903] [<ffffffff8124d833>] ? call_rwsem_down_write_failed+0x13/0x20
> [ 240.520907] [<ffffffff8124d833>] ? call_rwsem_down_write_failed+0x13/0x20
> [ 240.520913] [<ffffffff81423b22>] ? down_write+0x24/0x33
> [ 240.520923] [<ffffffff8110836e>] ? unlink_file_vma+0x28/0x4b
> [ 240.520928] [<ffffffff811033e4>] ? free_pgtables+0x3c/0xba
> [ 240.520933] [<ffffffff81107c15>] ? unmap_region+0xa4/0xc1
> [ 240.520941] [<ffffffff8106c60c>] ? pick_next_task_fair+0x11b/0x347
> [ 240.520947] [<ffffffff8110795f>] ? vma_gap_callbacks_propagate+0x16/0x2c
> [ 240.520951] [<ffffffff81108101>] ? vma_rb_erase+0x161/0x18f
> [ 240.520957] [<ffffffff81109524>] ? do_munmap+0x271/0x2e6
> [ 240.520962] [<ffffffff811095d0>] ? vm_munmap+0x37/0x4f
> [ 240.520967] [<ffffffff81109602>] ? SyS_munmap+0x1a/0x1f
> [ 240.520971] [<ffffffff81424d57>] ? entry_SYSCALL_64_fastpath+0x12/0x6a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
