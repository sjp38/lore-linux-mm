Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75B4B8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:27:27 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id v72so484123pgb.10
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:27:27 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j10si1612431plg.123.2019.01.14.15.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:27:26 -0800 (PST)
Subject: Re: [PATCHv2 6/7] x86/mm: remove bottom-up allocation style for
 x86_64
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-7-git-send-email-kernelfans@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fff8c6b6-7344-7ecb-b1a8-3c49af34c892@intel.com>
Date: Mon, 14 Jan 2019 15:27:25 -0800
MIME-Version: 1.0
In-Reply-To: <1547183577-20309-7-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On 1/10/19 9:12 PM, Pingfan Liu wrote:
> Although kaslr-kernel can avoid to stain the movable node. [1]

Can you explain what staining is, or perhaps try to use some more
standard nomenclature?  There are exactly 0 instances of the word
"stain" in arch/x86/ or mm/.

> But the
> pgtable can still stain the movable node. That is a probability problem,
> although low, but exist. This patch tries to make it certainty by
> allocating pgtable on unmovable node, instead of following kernel end.

Anyway, can you read my suggested summary in the earlier patch and see
if it fits or if I missed anything?  This description is really hard to
read.

...> +#ifdef CONFIG_X86_32
> +
> +static unsigned long min_pfn_mapped;
> +
>  static unsigned long __init get_new_step_size(unsigned long step_size)
>  {
>  	/*
> @@ -653,6 +655,32 @@ static void __init memory_map_bottom_up(unsigned long map_start,
>  	}
>  }
>  
> +static unsigned long __init init_range_memory_mapping32(
> +	unsigned long r_start, unsigned long r_end)
> +{

Why is this returning a value which is not used?

Did you compile this?  Didn't you get a warning that you're not
returning a value from a function returning non-void?

Also, I'd much rather see something like this written:

static __init
unsigned long init_range_memory_mapping32(unsigned long r_start,
					  unsigned long r_end)

than what you have above.  But, if you get rid of the 'unsigned long',
it will look much more sane in the first place.
