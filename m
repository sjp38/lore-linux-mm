Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 977F06B06BD
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 09:23:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c2so6207465qkb.10
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:23:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c126si12484911qkf.167.2017.08.03.06.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 06:23:53 -0700 (PDT)
Date: Thu, 3 Aug 2017 15:23:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2 ->
 crc32)
Message-ID: <20170803132350.GI21775@redhat.com>
References: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
 <20170801200550.GB24406@redhat.com>
 <bf406908-bf93-83dd-54e6-d2e3e5881db6@os.korea.ac.kr>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <bf406908-bf93-83dd-54e6-d2e3e5881db6@os.korea.ac.kr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sioh Lee <solee@os.korea.ac.kr>
Cc: akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On Thu, Aug 03, 2017 at 02:26:27PM +0900, sioh Lee wrote:
> Thank you very much for reading and responding to my commit.
> I understand the problem with crc32 you describe.
> I will investigate a?? as the first step, I will try to compare the number of CoWs with jhash2 and crc32. And I will send you the experiment results.

Also the number of KSM merges and ideally in a non simple workload. If
the hash triggers false positives it's not just that there will be
more CoWs, but the unstable tree will get more unstable and its
ability to find equality will decrease. This is why I don't like to
weaken the hash with a crc and I'd rather prefer to keep a real hash
there (doesn't need to be a crypto one, but it'd be even better if it
was).

The hash isn't used to find equality, it's only used to find which
pages are updated frequently (and if an app overwrites the same value
over and over, not even a crypto hash would be capable to detect it).

There were attempts to replace the hashing with a dirty bit set in
hardware in the pagetable in fact, that would be the ideal way, but
it's quite more complicated that way.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
