Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A14CC6B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 18:30:50 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id c2-v6so8056383plo.21
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 15:30:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k191si2665081pgd.449.2018.04.03.15.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 15:30:49 -0700 (PDT)
Date: Tue, 3 Apr 2018 15:30:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/migrate: properly preserve write attribute in
 special migrate entry
Message-Id: <20180403153046.88cae4ab18646e8e23a648ce@linux-foundation.org>
In-Reply-To: <20180402023506.12180-1-jglisse@redhat.com>
References: <20180402023506.12180-1-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>

On Sun,  1 Apr 2018 22:35:06 -0400 jglisse@redhat.com wrote:

> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> Use of pte_write(pte) is only valid for present pte, the common code
> which set the migration entry can be reach for both valid present
> pte and special swap entry (for device memory). Fix the code to use
> the mpfn value which properly handle both cases.
> 
> On x86 this did not have any bad side effect because pte write bit
> is below PAGE_BIT_GLOBAL and thus special swap entry have it set to
> 0 which in turn means we were always creating read only special
> migration entry.

Does this mean that the patch only affects behaviour of non-x86 systems?

> So once migration did finish we always write protected the CPU page
> table entry (moreover this is only an issue when migrating from device
> memory to system memory). End effect is that CPU write access would
> fault again and restore write permission.

That sounds a bit serious.  Was a -stable backport considered?
