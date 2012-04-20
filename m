Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 49BFC6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 16:06:01 -0400 (EDT)
Date: Fri, 20 Apr 2012 13:05:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix off-by-one bug in print_nodes_state
Message-Id: <20120420130558.6cdb55bb.akpm@linux-foundation.org>
In-Reply-To: <1322322173-14401-1-git-send-email-ozaki.ryota@gmail.com>
References: <1322322173-14401-1-git-send-email-ozaki.ryota@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Cc: linux-mm@kvack.org, stable@kernel.org

On Sun, 27 Nov 2011 00:42:53 +0900
Ryota Ozaki <ozaki.ryota@gmail.com> wrote:

> /sys/devices/system/node/{online,possible} involve a garbage byte
> because print_nodes_state returns content size + 1. To fix the bug,
> the patch changes the use of cpuset_sprintf_cpulist to follow the
> use at other places, which is clearer and safer.
> 
> This bug was introduced since v2.6.24 (bde631a51876f23e9).
> 
> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
> ---
>  drivers/base/node.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 5693ece..ef7c1f9 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -587,11 +587,9 @@ static ssize_t print_nodes_state(enum node_states state, char *buf)
>  {
>  	int n;
>  
> -	n = nodelist_scnprintf(buf, PAGE_SIZE, node_states[state]);
> -	if (n > 0 && PAGE_SIZE > n + 1) {
> -		*(buf + n++) = '\n';
> -		*(buf + n++) = '\0';
> -	}
> +	n = nodelist_scnprintf(buf, PAGE_SIZE-2, node_states[state]);
> +	buf[n++] = '\n';
> +	buf[n] = '\0';
>  	return n;
>  }

The patch looks good, thanks.

I have issues with the lib/bitmap.c documentation, btw.  Could someone
please double-check this?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: lib/bitmap.c: fix documentation for scnprintf() functions

The code comments for bscnl_emit() and bitmap_scnlistprintf() are
describing snprintf() return semantics, but these functions use
scnprintf() return semantics.  Fix that, and document the
bitmap_scnprintf() return value as well.

Cc: Ryota Ozaki <ozaki.ryota@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/bitmap.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff -puN lib/bitmap.c~a lib/bitmap.c
--- a/lib/bitmap.c~a
+++ a/lib/bitmap.c
@@ -369,7 +369,8 @@ EXPORT_SYMBOL(bitmap_find_next_zero_area
  * @nmaskbits: size of bitmap, in bits
  *
  * Exactly @nmaskbits bits are displayed.  Hex digits are grouped into
- * comma-separated sets of eight digits per set.
+ * comma-separated sets of eight digits per set.  Returns the number of
+ * characters which were written to *buf, excluding the trailing \0.
  */
 int bitmap_scnprintf(char *buf, unsigned int buflen,
 	const unsigned long *maskp, int nmaskbits)
@@ -517,8 +518,8 @@ EXPORT_SYMBOL(bitmap_parse_user);
  *
  * Helper routine for bitmap_scnlistprintf().  Write decimal number
  * or range to buf, suppressing output past buf+buflen, with optional
- * comma-prefix.  Return len of what would be written to buf, if it
- * all fit.
+ * comma-prefix.  Return len of what was written to *buf, excluding the
+ * trailing \0.
  */
 static inline int bscnl_emit(char *buf, int buflen, int rbot, int rtop, int len)
 {
@@ -544,9 +545,8 @@ static inline int bscnl_emit(char *buf, 
  * the range.  Output format is compatible with the format
  * accepted as input by bitmap_parselist().
  *
- * The return value is the number of characters which would be
- * generated for the given input, excluding the trailing '\0', as
- * per ISO C99.
+ * The return value is the number of characters which were written to *buf
+ * excluding the trailing '\0', as per ISO C99's scnprintf.
  */
 int bitmap_scnlistprintf(char *buf, unsigned int buflen,
 	const unsigned long *maskp, int nmaskbits)
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
