Date: Fri, 11 Mar 2005 14:52:26 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm counter operations through macros
Message-Id: <20050311145226.6ee4a951.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
	<20050311182500.GA4185@redhat.com>
	<Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: davej@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> This patch extracts all the operations on counters protected by the
> page table lock (currently rss and anon_rss) into definitions in
> include/linux/sched.h. All rss operations are performed through
> the following macros:
>
> get_mm_counter(mm, member)		-> Obtain the value of a counter
> set_mm_counter(mm, member, value)	-> Set the value of a counter
> update_mm_counter(mm, member, value)	-> Add to a counter
> inc_mm_counter(mm, member)		-> Increment a counter
> dec_mm_counter(mm, member)		-> Decrement a counter

I spose it makes sense, if we'll be making scalability changes in there.

> 
> +#define set_mm_counter(mm, member, value) (mm)->member = (value)
> +#define get_mm_counter(mm, member) ((mm)->member)
> +#define update_mm_counter(mm, member, value) (mm)->member += (value)
> +#define inc_mm_counter(mm, member) (mm)->member++
> +#define dec_mm_counter(mm, member) (mm)->member--
> +#define MM_COUNTER_T unsigned long

Would prefer `mm_counter_t' here.

Why not a typedef?

> @@ -231,9 +237,13 @@ struct mm_struct {
>  	unsigned long start_code, end_code, start_data, end_data;
>  	unsigned long start_brk, brk, start_stack;
>  	unsigned long arg_start, arg_end, env_start, env_end;
> -	unsigned long rss, anon_rss, total_vm, locked_vm, shared_vm;
> +	unsigned long total_vm, locked_vm, shared_vm;
>  	unsigned long exec_vm, stack_vm, reserved_vm, def_flags, nr_ptes;
> 
> +	/* Special counters protected by the page_table_lock */
> +	MM_COUNTER_T rss;
> +	MM_COUNTER_T anon_rss;
> +

Why were only two counters converted?

Could I suggest that you rename all these counters, so that code which
fails to use the macros won't compile?

That renaming can be hidden in the header file: add an underscore to the
front of all the identifiers, paste that underscore back within the macros.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
