Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 228B66B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 05:16:39 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m184so15725171qkb.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 02:16:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g79si14362330wme.57.2016.08.15.02.16.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Aug 2016 02:16:37 -0700 (PDT)
Subject: Re: OOM killer changes
References: <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
Date: Mon, 15 Aug 2016 11:16:36 +0200
MIME-Version: 1.0
In-Reply-To: <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/15/2016 06:48 AM, Ralf-Peter Rohbeck wrote:
> On 02.08.2016 12:25, Ralf-Peter Rohbeck wrote:
>>
> Took me a little longer than expected due to work. The failure wouldn't 
> happen for a while and so I started a couple of scripts and let them 
> run. When I checked today the server didn't respond on the network and 
> sure enough it had killed everything. This is with 4.7.0 with the config 
> based on Debian 4.7-rc7.
> 
> trace_pipe got a little big (5GB) so I uploaded the logs to 
> https://filebin.net/box0wycfouvhl6sr/OOM_4.7.0.tar.bz2. before_btrfs is 
> before the btrfs filesystems were mounted.
> I did run a btrfs balance because it creates IO load and I needed to 
> balance anyway. Maybe that's what caused it?

pgmigrate_success        46738962
pgmigrate_fail          135649772
compact_migrate_scanned 309726659
compact_free_scanned   9715615169
compact_isolated        229689596
compact_stall 4777
compact_fail 3068
compact_success 1709
compact_daemon_wake 207834

The migration failures are quite enormous. Very quick analysis of the
trace seems to confirm that these are mostly "real", as opposed to result
of failure to isolate free pages for migration targets, although the free
scanner spent a lot of time:

> grep "nr_failed=32" -B1 trace_pipe.log | grep isolate_freepages.*nr_taken=0 | wc -l
3246

So is it one of the cases where fs is unable to migrate dirty/writeback pages?

Vlastimil

> I'll make the changes requested by Michal and try again.
> 
> Thanks,
> Ralf-Peter
> 
> 
> ----------------------------------------------------------------------
> The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
