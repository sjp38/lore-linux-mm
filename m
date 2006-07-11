Date: Tue, 11 Jul 2006 04:12:09 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] out of memory notifier - 2nd try.
Message-Id: <20060711041209.1c9cee49.akpm@osdl.org>
In-Reply-To: <20060711105148.GA28648@skybase>
References: <20060711105148.GA28648@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2006 12:51:48 +0200
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> Hi folks,
> I did not get any negative nor positive feedback on my proposed out of
> memory notifier patch. I'm optimistic that this means that nobody has
> anything against it ..

I have some negative feedback! ;)

>  cmm_alloc_pages(long pages, long *counter, struct cmm_page_array **list)
>  {
> -	struct cmm_page_array *pa;
> +	struct cmm_page_array *pa, *npa;
>  	unsigned long page;
>  
> -	pa = *list;
>  	while (pages) {
>  		page = __get_free_page(GFP_NOIO);

There's a strong convention of

	struct page *page;
	struct page *pages;

Calling your locals which don't point at struct page's "page" makes the
code harder to follow for experienced kernel developers.


>  static int
>  cmm_thread(void *dummy)
>  {
> @@ -419,6 +452,7 @@ cmm_init (void)
>  #ifdef CONFIG_CMM_IUCV
>  	smsg_register_callback(SMSG_PREFIX, cmm_smsg_target);
>  #endif
> +	register_oom_notifier(&cmm_oom_nb);
>  	INIT_WORK(&cmm_thread_starter, (void *) cmm_start_thread, NULL);
>  	init_waitqueue_head(&cmm_thread_wait);
>  	init_timer(&cmm_timer);
> @@ -428,6 +462,7 @@ cmm_init (void)
>  static void
>  cmm_exit(void)
>  {
> +	unregister_oom_notifier(&cmm_oom_nb);

But I think the oom-handler callback could be executing while it gets
unregistered and rmmodded.

> +static struct notifier_block *oom_notify_list = 0;

Unneeded initialisation.

> +int register_oom_notifier(struct notifier_block *nb)
> +{
> +	return notifier_chain_register(&oom_notify_list, nb);
> +}
> +EXPORT_SYMBOL_GPL(register_oom_notifier);
> +
> +int unregister_oom_notifier(struct notifier_block *nb)
> +{
> +	return notifier_chain_unregister(&oom_notify_list, nb);
> +}
> +EXPORT_SYMBOL_GPL(unregister_oom_notifier);

If one of the locked notifier-chain APIs was used (ie: blocking_notifier*),
I think the above race wouldn't be present.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
