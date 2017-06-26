Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF686B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 12:46:38 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r145so3678497itr.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 09:46:38 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id x65si13110itd.3.2017.06.26.09.46.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 09:46:37 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id h64so4085027iod.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 09:46:37 -0700 (PDT)
Subject: Re: [PATCH v2 00/51] block: support multipage bvec
References: <20170626121034.3051-1-ming.lei@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <39115560-8d40-3528-e90e-7ccfe9551a10@kernel.dk>
Date: Mon, 26 Jun 2017 10:46:34 -0600
MIME-Version: 1.0
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 06/26/2017 06:09 AM, Ming Lei wrote:
> Hi,
> 
> This patchset brings multipage bvec into block layer:
> 
> 1) what is multipage bvec?
> 
> Multipage bvecs means that one 'struct bio_bvec' can hold
> multiple pages which are physically contiguous instead
> of one single page used in linux kernel for long time.
> 
> 2) why is multipage bvec introduced?
> 
> Kent proposed the idea[1] first. 
> 
> As system's RAM becomes much bigger than before, and 
> at the same time huge page, transparent huge page and
> memory compaction are widely used, it is a bit easy now
> to see physically contiguous pages from fs in I/O.
> On the other hand, from block layer's view, it isn't
> necessary to store intermediate pages into bvec, and
> it is enough to just store the physicallly contiguous
> 'segment' in each io vector.
> 
> Also huge pages are being brought to filesystem and swap
> [2][6], we can do IO on a hugepage each time[3], which
> requires that one bio can transfer at least one huge page
> one time. Turns out it isn't flexiable to change BIO_MAX_PAGES
> simply[3][5]. Multipage bvec can fit in this case very well.
> 
> With multipage bvec:
> 
> - segment handling in block layer can be improved much
> in future since it should be quite easy to convert
> multipage bvec into segment easily. For example, we might 
> just store segment in each bvec directly in future.
> 
> - bio size can be increased and it should improve some
> high-bandwidth IO case in theory[4].
> 
> - Inside block layer, both bio splitting and sg map can
> become more efficient than before by just traversing the
> physically contiguous 'segment' instead of each page.
> 
> - there is opportunity in future to improve memory footprint
> of bvecs. 
> 
> 3) how is multipage bvec implemented in this patchset?
> 
> The 1st 18 patches comment on some special cases and deal with
> some special cases of direct access to bvec table.
> 
> The 2nd part(19~29) implements multipage bvec in block layer:
> 
> 	- put all tricks into bvec/bio/rq iterators, and as far as
> 	drivers and fs use these standard iterators, they are happy
> 	with multipage bvec
> 
> 	- use multipage bvec to split bio and map sg
> 
> 	- bio_for_each_segment_all() changes
> 	this helper pass pointer of each bvec directly to user, and
> 	it has to be changed. Two new helpers(bio_for_each_segment_all_sp()
> 	and bio_for_each_segment_all_mp()) are introduced. 
> 
> The 3rd part(30~49) convert current users of bio_for_each_segment_all()
> to bio_for_each_segment_all_sp()/bio_for_each_segment_all_mp().
> 
> The last part(50~51) enables multipage bvec.
> 
> These patches can be found in the following git tree:
> 
> 	https://github.com/ming1/linux/commits/mp-bvec-1.4-v4.12-rc
> 
> Thanks Christoph for looking at the early version and providing
> very good suggestions, such as: introduce bio_init_with_vec_table(),
> remove another unnecessary helpers for cleanup and so on.
> 
> Any comments are welcome!

I'll take some time to review this over the next week or so. In any
case, it's a little late to stuff into 4.13 and get a decent amount
of exposure and testing on it. A 4.14 target for this would be the
way to go, imho.


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
