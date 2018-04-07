Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C80DC6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 22:59:41 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 91-v6so2227936plf.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 19:59:41 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 4-v6si10388922pld.371.2018.04.06.19.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 19:59:40 -0700 (PDT)
Subject: Re: find_swap_entry sparse cleanup
References: <ffad6db6-85b1-59b2-bc5e-5492d1c175ac@oracle.com>
 <20180407022849.GA24377@bombadil.infradead.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d82bced0-5f6b-2959-28d2-3a7d900b6f05@oracle.com>
Date: Fri, 6 Apr 2018 19:59:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180407022849.GA24377@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On 04/06/2018 07:28 PM, Matthew Wilcox wrote:
> I'm happy to help clean this up in advance of the XArray code going in ...
> 
> This loop is actually buggy in two or three different ways.  Here's how
> it should have looked:
> 
> @@ -1098,13 +1098,18 @@ static void shmem_evict_inode(struct inode *inode)
>  static unsigned long find_swap_entry(struct radix_tree_root *root, void *item)
>  {
>         struct radix_tree_iter iter;
> -       void **slot;
> +       void __rcu **slot;
>         unsigned long found = -1;
>         unsigned int checked = 0;
>  
>         rcu_read_lock();
>         radix_tree_for_each_slot(slot, root, &iter, 0) {
> -               if (*slot == item) {
> +               void *entry = radix_tree_deref_slot(slot);
> +               if (radix_tree_deref_retry(entry)) {
> +                       slot = radix_tree_iter_retry(&iter);
> +                       continue;
> +               }
> +               if (entry == item) {
>                         found = iter.index;
>                         break;
>                 }
> 

Thank you!  I was worried about searching for swap entries that would
be marked RADIX_TREE_EXCEPTIONAL_ENTRY.  Your changes above make perfect
sense.  Do you mind if I roll them into a patch that adds all the other
missing __rcu annotations in the file, and add your Signed-off-by?

-- 
Mike Kravetz
