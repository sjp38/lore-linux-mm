Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05F9B6B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 16:26:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j12so7035118pff.18
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 13:26:18 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n8si10710794pff.122.2018.03.05.13.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 13:26:18 -0800 (PST)
Subject: Re: [PATCH v12 10/11] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <08ef65c1-16b3-44e7-5cc3-7b6bde7bd5a4@linux.intel.com>
Date: Mon, 5 Mar 2018 13:26:16 -0800
MIME-Version: 1.0
In-Reply-To: <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, akpm@linux-foundation.org
Cc: corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, rob.gardner@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, anthony.yznaga@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, allen.pais@oracle.com, tklauser@distanz.ch, shannon.nelson@oracle.com, vijay.ac.kumar@oracle.com, mhocko@suse.com, jack@suse.cz, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aarcange@redhat.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, gregkh@linuxfoundation.org, nagarathnam.muthusamy@oracle.com, linux@roeck-us.net, jane.chu@oracle.com, dan.j.williams@intel.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 02/21/2018 09:15 AM, Khalid Aziz wrote:
> +tag_storage_desc_t *alloc_tag_store(struct mm_struct *mm,
> +				    struct vm_area_struct *vma,
> +				    unsigned long addr)
...
> +	tags = kzalloc(size, GFP_NOWAIT|__GFP_NOWARN);
> +	if (tags == NULL) {
> +		tag_desc->tag_users = 0;
> +		tag_desc = NULL;
> +		goto out;
> +	}
> +	tag_desc->start = addr;
> +	tag_desc->tags = tags;
> +	tag_desc->end = end_addr;
> +
> +out:
> +	spin_unlock_irqrestore(&mm->context.tag_lock, flags);
> +	return tag_desc;
> +}

OK, sorry, I missed this.  I do see that you now have per-ADI-block tag
storage and it is not per-page.

How big can this storage get, btw?  Superficially it seems like it might
be able to be gigantic for a large, sparse VMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
