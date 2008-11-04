Subject: Re: [RFC v8][PATCH 05/12] x86 support for checkpoint/restart
From: Masahiko Takahashi <m-takahashi@ex.jp.nec.com>
In-Reply-To: <1225374675-22850-6-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
	 <1225374675-22850-6-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain
Date: Tue, 04 Nov 2008 18:30:16 +0900
Message-Id: <1225791016.5940.33.camel@noir.spf.cl.nec.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linus Torvalds <torvalds@osdl.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Oren,

I'm now trying to port your patchset to x86_64, and find a tiny
inconsistency issue.


On 2008-10-30 at 09:51 -0400, Oren Laadan wrote:
> +/* dump the thread_struct of a given task */
> +int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct thread_struct *thread;
> +	struct desc_struct *desc;
> +	int ntls = 0;
> +	int n, ret;
> +
> +	h.type = CR_HDR_THREAD;
> +	h.len = sizeof(*hh);
> +	h.parent = task_pid_vnr(t);
> +
> +	thread = &t->thread;
> +
> +	/* calculate no. of TLS entries that follow */
> +	desc = thread->tls_array;
> +	for (n = GDT_ENTRY_TLS_ENTRIES; n > 0; n--, desc++) {
> +		if (desc->a || desc->b)
> +			ntls++;
> +	}
> +
> +	hh->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
> +	hh->sizeof_tls_array = sizeof(thread->tls_array);
> +	hh->ntls = ntls;
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	if (ret < 0)
> +		return ret;

Please add
   if (ntls == 0)
            return ret;
because, in restart phase, reading TLS entries from the image file
is skipped if hh->ntls == 0, which may incur inconsistency and fail
to restart.

> +	/* for simplicity dump the entire array, cherry-pick upon restart */
> +	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
> +
> +	cr_debug("ntls %d\n", ntls);
> +
> +	/* IGNORE RESTART BLOCKS FOR NOW ... */
> +
> +	return ret;
> +}
(snip)
> +/* read the thread_struct into the current task */
> +int cr_read_thread(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct task_struct *t = current;
> +	struct thread_struct *thread = &t->thread;
> +	int parent, ret;
> +
> +	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_THREAD);
> +	if (parent < 0) {
> +		ret = parent;
> +		goto out;
> +	}
> +
> +	ret = -EINVAL;
> +
> +#if 0	/* activate when containers are used */
> +	if (parent != task_pid_vnr(t))
> +		goto out;
> +#endif
> +	cr_debug("ntls %d\n", hh->ntls);
> +
> +	if (hh->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES ||
> +	    hh->sizeof_tls_array != sizeof(thread->tls_array) ||
> +	    hh->ntls < 0 || hh->ntls > GDT_ENTRY_TLS_ENTRIES)
> +		goto out;
> +
> +	if (hh->ntls > 0) {
> +		struct desc_struct *desc;
> +		int size, cpu;
> +
> +		/*
> +		 * restore TLS by hand: why convert to struct user_desc if
> +		 * sys_set_thread_entry() will convert it back ?
> +		 */
> +
> +		size = sizeof(*desc) * GDT_ENTRY_TLS_ENTRIES;
> +		desc = kmalloc(size, GFP_KERNEL);
> +		if (!desc)
> +			return -ENOMEM;
> +
> +		ret = cr_kread(ctx, desc, size);
> +		if (ret >= 0) {
> +			/*
> +			 * FIX: add sanity checks (eg. that values makes
> +			 * sense, that we don't overwrite old values, etc
> +			 */
> +			cpu = get_cpu();
> +			memcpy(thread->tls_array, desc, size);
> +			load_TLS(thread, cpu);
> +			put_cpu();
> +		}
> +		kfree(desc);
> +	}
> +
> +	ret = 0;
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	return ret;
> +}


Thanks,

Masahiko.

---
Masahiko Takahashi / m-takahashi@ex.jp.nec.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
