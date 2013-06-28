Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 9FAA96B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:43:21 -0400 (EDT)
Date: Fri, 28 Jun 2013 17:38:28 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: mmotm 2013-06-27-16-36 uploaded (wait event common)
Message-ID: <20130628153828.GA24371@redhat.com>
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com> <51CD1F81.4040202@infradead.org> <20130627225139.798e7b00.akpm@linux-foundation.org> <51CD27F3.30104@infradead.org> <20130628165641.2193bfcd78c1f27d6f68f9a5@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628165641.2193bfcd78c1f27d6f68f9a5@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On 06/28, Stephen Rothwell wrote:
>
> On Thu, 27 Jun 2013 23:06:43 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> >
> > >> My builds are littered with hundreds of warnings like this one:
> > >>
> > >> drivers/tty/tty_ioctl.c:220:6: warning: the omitted middle operand in ?: will always be 'true', suggest explicit middle operand [-Wparentheses]
> > >>
> > >> I guess due to this line from wait_event_common():
> > >>
> > >> +		__ret = __wait_no_timeout(tout) ?: (tout) ?: 1;
> > >>
> I added the following to linux-next today:
> (sorry Randy, I forgot the Reported-by:, Andrew please add)
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 28 Jun 2013 16:52:58 +1000
> Subject: [PATCH] fix warnings from ?: operator in wait.h

Argh. This patch strikes again.

Thanks, and sorry. And please help!

I am not sure I understand. Since when gcc dislikes '?:' ?
/bin/grep shows a lot of users of 'X ?: Y' shortcut?



> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  include/linux/wait.h | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/wait.h b/include/linux/wait.h
> index 1c08a6c..f3b793d 100644
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -197,7 +197,12 @@ wait_queue_head_t *bit_waitqueue(void *, int);
>  	for (;;) {							\
>  		__ret = prepare_to_wait_event(&wq, &__wait, state);	\
>  		if (condition) {					\
> -			__ret = __wait_no_timeout(tout) ?: __tout ?: 1;	\
> +			__ret = __wait_no_timeout(tout);		\
> +			if (!__ret) {					\
> +				__ret = __tout;				\
> +				if (!__ret)				\
> +					__ret = 1;			\
> +			}						\
>  			break;						\
>  		}							\
>  									\
> @@ -218,9 +223,14 @@ wait_queue_head_t *bit_waitqueue(void *, int);
>  #define wait_event_common(wq, condition, state, tout)			\
>  ({									\
>  	long __ret;							\
> -	if (condition)							\
> -		__ret = __wait_no_timeout(tout) ?: (tout) ?: 1;		\
> -	else								\
> +	if (condition) {						\
> +		__ret = __wait_no_timeout(tout);			\
> +		if (!__ret) {						\
> +			__ret = (tout);					\
> +			if (!__ret)					\
> +				__ret = 1;				\
> +		}							\
> +	} else								\
>  		__ret = __wait_event_common(wq, condition, state, tout);\
>  	__ret;								\
>  })
> -- 
> 1.8.3.1
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
