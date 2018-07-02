Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2BA66B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 15:47:32 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so10494145pll.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 12:47:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q8-v6si2620870pfh.353.2018.07.02.12.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 12:47:31 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-3-pasha.tatashin@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <552d5a9b-0ca9-cc30-d8c2-33dc1cde917f@intel.com>
Date: Mon, 2 Jul 2018 12:47:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180702020417.21281-3-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/01/2018 07:04 PM, Pavel Tatashin wrote:
> +	for_each_present_section_nr(pnum_begin + 1, pnum_end) {
> +		int nid = sparse_early_nid(__nr_to_section(pnum_end));
>  
> +		if (nid == nid_begin) {
> +			map_count++;
>  			continue;
>  		}

> +		sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
> +		nid_begin = nid;
> +		pnum_begin = pnum_end;
> +		map_count = 1;
>  	}

Ugh, this is really hard to read.  Especially because the pnum "counter"
is called "pnum_end".

So, this is basically a loop that collects all of the adjacent sections
in a given single nid and then calls sparse_init_nid().  pnum_end in
this case is non-inclusive, so the sparse_init_nid() call is actually
for the *previous* nid that pnum_end is pointing _past_.

This *really* needs commenting.
