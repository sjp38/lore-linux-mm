Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC94A6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 03:43:49 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g124so220808238qkd.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 00:43:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 201si24401921wmb.59.2016.08.17.00.43.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Aug 2016 00:43:48 -0700 (PDT)
Subject: Re: OOM killer changes
References: <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160815150123.GG3360@dhcp22.suse.cz>
 <1b8ee89d-a851-06f0-6bcc-62fef9e7e7cc@Quantum.com>
 <20160816073246.GC5001@dhcp22.suse.cz>
 <57621ed5-f517-29c8-983c-da2257c0b4a6@Quantum.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5d141376-0fd9-a13a-87c6-16676d5d7730@suse.cz>
Date: Wed, 17 Aug 2016 09:43:47 +0200
MIME-Version: 1.0
In-Reply-To: <57621ed5-f517-29c8-983c-da2257c0b4a6@Quantum.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/17/2016 02:26 AM, Ralf-Peter Rohbeck wrote:
> No it wasn't yet in the last run. That OOM happened while I compiled the 
> last change.

You mean those pr_infos?

>From those we've got:

Aug 16 17:14:26 fs kernel: [ 1817.044778] XXX: compaction_failed
Aug 16 17:15:37 fs kernel: [ 1888.387817] XXX: compaction_failed
Aug 16 17:17:32 fs kernel: [ 2002.879726] XXX: compaction_failed

e.g. none of the "XXX: no zone suitable for compaction" lines

I think my series in mmotm tree could help here.

> I ran another test with the trace_printk: See attached. Again I ran only 
> a kernel compilation.

so, the trace_printk didn't hit that many times:

grep try_to_release trace_pipe.log | wc -l
52

and vmstat_after shows:

pgmigrate_success 851
pgmigrate_fail 817
compact_migrate_scanned 567689
compact_free_scanned 50744242
compact_isolated 19196
compact_stall 876
compact_fail 801
compact_success 75

pagetype_after:

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic      Isolate 
Node 0, zone      DMA            1            7            0            0            0 
Node 0, zone    DMA32          883           91           42            0            0 
Node 0, zone   Normal         2750          207          115            0            0 

So while btrfs migrate failures could be real, in this run it was rather the free
scanner struggling due to unmovable blocks, as Joonsoo suggested.

> Ralf-Peter
> 
> On 16.08.2016 00:32, Michal Hocko wrote:
>> On Mon 15-08-16 11:42:11, Ralf-Peter Rohbeck wrote:
>>> This time the OOM killer hit much quicker. No btrfs balance, just compiling
>>> the kernel with the new change did it.
>>> Much smaller logs so I'm attaching them.
>> Just to clarify. You have added the trace_printk for
>> try_to_release_page, right? (after fixing it of course). If yes there is
>> no single mention of that path failing which would support Joonsoo's
>> theory... Could you try with his patch?
> 
> 
> ----------------------------------------------------------------------
> The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
