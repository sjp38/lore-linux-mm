Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3CC096B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 14:46:37 -0500 (EST)
Message-ID: <50F5B214.5060604@zytor.com>
Date: Tue, 15 Jan 2013 11:46:28 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFCv3][PATCH 1/3] create slow_virt_to_phys()
References: <20130109185904.DD641DCE@kernel.stglabs.ibm.com>
In-Reply-To: <20130109185904.DD641DCE@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 01/09/2013 10:59 AM, Dave Hansen wrote:
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		psize = PAGE_SIZE;
> +		pmask = PAGE_MASK;
> +		break;
> +	case PG_LEVEL_2M:
> +		psize = PMD_PAGE_SIZE;
> +		pmask = PMD_PAGE_MASK;
> +		break;
> +#ifdef CONFIG_X86_64
> +	case PG_LEVEL_1G:
> +		psize = PUD_PAGE_SIZE;
> +		pmask = PUD_PAGE_MASK;
> +		break;
> +#endif
> +	default:
> +		BUG();
> +	}

I object to this switch statement.  If we are going to create new 
primitives, let's create a primitive that embody this and put it in 
pgtypes_types.h, especially since it is simply an algorithmic operation:

static inline unsigned long page_level_size(int level)
{
	return (PAGE_SIZE/PGDIR_SIZE) << (PGDIR_SHIFT*level);
}
static inline unsigned long page_level_shift(int level)
{
	return (PAGE_SHIFT-PGDIR_SHIFT) + (PGDIR_SHIFT*level);
}

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
