Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4463A6B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:16:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so58118541wmz.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 03:16:18 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id eb3si17793489wjb.247.2016.08.22.03.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 03:16:16 -0700 (PDT)
Date: Mon, 22 Aug 2016 12:16:14 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160822101614.GA314@x4>
References: <20160822093249.GA14916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822093249.GA14916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2016.08.22 at 11:32 +0200, Michal Hocko wrote:
> there have been multiple reports [1][2][3][4][5] about pre-mature OOM
> killer invocations since 4.7 which contains oom detection rework. All of
> them were for order-2 (kernel stack) alloaction requests failing because
> of a high fragmentation and compaction failing to make any forward
> progress. While investigating this we have found out that the compaction
> just gives up too early. Vlastimil has been working on compaction
> improvement for quite some time and his series [6] is already sitting
> in mmotm tree. This already helps a lot because it drops some heuristics
> which are more aimed at lower latencies for high orders rather than
> reliability. Joonsoo has then identified further problem with too many
> blocks being marked as unmovable [7] and Vlastimil has prepared a patch
> on top of his series [8] which is also in the mmotm tree now.
> 
> That being said, the regression is real and should be fixed for 4.7
> stable users. [6][8] was reported to help and ooms are no longer
> reproducible. I know we are quite late (rc3) in 4.8 but I would vote
> for mergeing those patches and have them in 4.8. For 4.7 I would go
> with a partial revert of the detection rework for high order requests
> (see patch below). This patch is really trivial. If those compaction
> improvements are just too large for 4.8 then we can use the same patch
> as for 4.7 stable for now and revert it in 4.9 after compaction changes
> are merged.
> 
> Thoughts?
> 
> [1] http://lkml.kernel.org/r/20160731051121.GB307@x4

For the report [1] above:

markus@x4 linux % cat .config | grep CONFIG_COMPACTION
# CONFIG_COMPACTION is not set

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
