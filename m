Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id F29616B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 16:12:30 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id d46so1516947wer.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 13:12:29 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1364984183-9711-3-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com> <1364984183-9711-3-git-send-email-liwanp@linux.vnet.ibm.com>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Wed, 3 Apr 2013 16:12:09 -0400
Message-ID: <CAPbh3rs2EP=k0yqt1YBNhx8GP_usmaRT=0J3au3Y_8Ei4J5fxg@mail.gmail.com>
Subject: Re: [PATCH v6 2/3] staging: zcache: introduce zero-filled page stat count
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

On Wed, Apr 3, 2013 at 6:16 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Introduce zero-filled page statistics to monitor the number of
> zero-filled pages.
>
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/staging/zcache/debug.c       |    3 +++
>  drivers/staging/zcache/debug.h       |   17 +++++++++++++++++
>  drivers/staging/zcache/zcache-main.c |    4 ++++
>  3 files changed, 24 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/staging/zcache/debug.c b/drivers/staging/zcache/debug.c
> index faab2a9..daa2691 100644
> --- a/drivers/staging/zcache/debug.c
> +++ b/drivers/staging/zcache/debug.c
> @@ -35,6 +35,8 @@ ssize_t zcache_pers_ate_eph;
>  ssize_t zcache_pers_ate_eph_failed;
>  ssize_t zcache_evicted_eph_zpages;
>  ssize_t zcache_evicted_eph_pageframes;
> +ssize_t zcache_zero_filled_pages;
> +ssize_t zcache_zero_filled_pages_max;
>
>  #define ATTR(x)  { .name = #x, .val = &zcache_##x, }
>  static struct debug_entry {
> @@ -62,6 +64,7 @@ static struct debug_entry {
>         ATTR(last_inactive_anon_pageframes),
>         ATTR(eph_nonactive_puts_ignored),
>         ATTR(pers_nonactive_puts_ignored),
> +       ATTR(zero_filled_pages),
>  #ifdef CONFIG_ZCACHE_WRITEBACK
>         ATTR(outstanding_writeback_pages),
>         ATTR(writtenback_pages),
> diff --git a/drivers/staging/zcache/debug.h b/drivers/staging/zcache/debug.h
> index 8ec82d4..ddad92f 100644
> --- a/drivers/staging/zcache/debug.h
> +++ b/drivers/staging/zcache/debug.h
> @@ -122,6 +122,21 @@ static inline void dec_zcache_pers_zpages(unsigned zpages)
>         zcache_pers_zpages = atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
>  }
>
> +extern ssize_t zcache_zero_filled_pages;
> +static atomic_t zcache_zero_filled_pages_atomic = ATOMIC_INIT(0);
> +extern ssize_t zcache_zero_filled_pages_max;
> +static inline void inc_zcache_zero_filled_pages(void)
> +{
> +       zcache_zero_filled_pages = atomic_inc_return(
> +                                       &zcache_zero_filled_pages_atomic);
> +       if (zcache_zero_filled_pages > zcache_zero_filled_pages_max)
> +               zcache_zero_filled_pages_max = zcache_zero_filled_pages;
> +}
> +static inline void dec_zcache_zero_filled_pages(void)
> +{
> +       zcache_zero_filled_pages = atomic_dec_return(
> +                                       &zcache_zero_filled_pages_atomic);
> +}
>  static inline unsigned long curr_pageframes_count(void)
>  {
>         return zcache_pageframes_alloced -
> @@ -200,6 +215,8 @@ static inline void inc_zcache_eph_zpages(void) { };
>  static inline void dec_zcache_eph_zpages(unsigned zpages) { };
>  static inline void inc_zcache_pers_zpages(void) { };
>  static inline void dec_zcache_pers_zpages(unsigned zpages) { };
> +static inline void inc_zcache_zero_filled_pages(void) { };
> +static inline void dec_zcache_zero_filled_pages(void) { };
>  static inline unsigned long curr_pageframes_count(void)
>  {
>         return 0;
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 1994cab..f3de76d 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -374,6 +374,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>         if (page_is_zero_filled(page)) {
>                 clen = 0;
>                 zero_filled = true;
> +               inc_zcache_zero_filled_pages();
>                 goto got_pampd;
>         }
>
> @@ -440,6 +441,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>         if (page_is_zero_filled(page)) {
>                 clen = 0;
>                 zero_filled = true;
> +               inc_zcache_zero_filled_pages();
>                 goto got_pampd;
>         }
>
> @@ -652,6 +654,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>                 zpages = 1;
>                 if (!raw)
>                         *sizep = PAGE_SIZE;
> +               dec_zcache_zero_filled_pages();
>                 goto zero_fill;
>         }
>
> @@ -702,6 +705,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>                 zero_filled = true;
>                 zsize = 0;
>                 zpages = 1;
> +               dec_zcache_zero_filled_pages();
>         }
>
>         if (pampd_is_remote(pampd) && !zero_filled) {
> --
> 1.7.5.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
