Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id DF3B36B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 05:27:11 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id z12so15343123wgg.3
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 02:27:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si83216925eem.19.2014.01.06.02.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 02:27:10 -0800 (PST)
Date: Mon, 6 Jan 2014 11:27:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: add ulimit API for user
Message-ID: <20140106102707.GA23730@dhcp22.suse.cz>
References: <52C28AAA.5060707@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52C28AAA.5060707@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: riel@redhat.com, walken@google.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, wangnan0@huawei.com

On Tue 31-12-13 17:13:14, Xishi Qiu wrote:
> Add ulimit API for users. When memory is not enough, 
> user's app will receive a signal, and it can do something
> in the handler.
> 
> e.g.
> #include <sys/mman.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> void handler(int sig)
> {
> char *b = malloc(1000000000);
> memset(b, '\0', 1000000000);
> printf("catch the signal by wwy\n");
> exit(1);
> }
> int main ( int argc, char *argv[] )
> {
> struct rlimit r1 = { 3600000000, 3600000000};
> setrlimit(RLIMIT_AS, &r1);
> signal(47, &handler);
> char * a = malloc(3600000000);
> int fd=open("/home/wayne/qemu.tar.bz2", O_RDONLY);
> char abc[2000000] = {'\0'};
> mmap(NULL, 10000000, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd , 0);
> sleep(100);
> free(a);
> while(1){
> }
> }
> 
> RTOS-x86_64 /tmp # ./a.out
> catch the signal by wwy

How does this demonstrate the newly added knob?
 
[...]
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 4ff7f52..a10155f 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2402,6 +2402,11 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>   * Return true if the calling process may expand its vm space by the passed
>   * number of pages
>   */
> +
> +#ifdef CONFIG_ULIMIT_VM_SIG
> +unsigned long vm_expand_signal_enable = 0;
> +EXPORT_SYMBOL(vm_expand_signal_enable);
> +#endif
> +
>  int may_expand_vm(struct mm_struct *mm, unsigned long npages)
>  {
>  	unsigned long cur = mm->total_vm;	/* pages */
> @@ -2410,7 +2415,9 @@ int may_expand_vm(struct mm_struct *mm, unsigned long npages)
>  	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
>  
>  	if (cur + npages > lim){
> -		send_sig(SIGRTMIN+15, current, 1);

What kind of tree is this based on? Neither Linus' nor Andrew's tree
sends the signal. And I would be really surprised if such a change would
be accepted at all because may_expand_vm is not supposed to send a
signal. Only automatic stack expansion is supposed to send SEGV other
callers should simply return ENOMEM

> +#ifdef	CONFIG_ULIMIT_VM_SIG
> +		if (vm_expand_signal_enable){
> +			send_sig(SIGRTMIN+15, current, 1);
> +		}
> +#endif
>  		return 0;
>  	}
>  	return 1;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
