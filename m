Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3C9B6B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:36:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k83so73622913pfa.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:36:31 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 126si41969590pff.262.2016.09.07.09.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 09:34:26 -0700 (PDT)
Subject: Re: [PATCH] Fix region lost in /proc/self/smaps
References: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D04192.5070704@intel.com>
Date: Wed, 7 Sep 2016 09:34:26 -0700
MIME-Version: 1.0
In-Reply-To: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <guangrong.xiao@linux.intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com
Cc: gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/06/2016 11:51 PM, Xiao Guangrong wrote:
> In order to fix this bug, we make 'file->version' indicate the next VMA
> we want to handle

This new approach makes it more likely that we'll skip a new VMA that
gets inserted in between the read()s.  But, I guess that's OK.  We don't
exactly claim to be giving super up-to-date data at the time of read().

With the old code, was there also a case that we could print out the
same virtual address range more than once?  It seems like that could
happen if we had a VMA split between two reads.

I think this introduces one oddity: if you have a VMA merge between two
reads(), you might get the same virtual address range twice in your
output.  This didn't happen before because we would have just skipped
over the area that got merged.

Take two example VMAs:

	vma-A: (0x1000 -> 0x2000)
	vma-B: (0x2000 -> 0x3000)

read() #1: prints vma-A, sets m->version=0x2000

Now, merge A/B to make C:

	vma-C: (0x1000 -> 0x3000)

read() #2: find_vma(m->version=0x2000), returns vma-C, prints vma-C

The user will see two VMAs in their output:

	A: 0x1000->0x2000
	C: 0x1000->0x3000

Will it confuse them to see the same virtual address range twice?  Or is
there something preventing that happening that I'm missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
