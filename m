Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E0FD6B0082
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 05:37:04 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090629201014.GA5414@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
Content-Type: text/plain
Date: Tue, 14 Jul 2009 11:07:13 +0100
Message-Id: <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 2009-06-29 at 21:10 +0100, Sergey Senozhatsky wrote:
> This is actually draft. We'll discuss details during next merge window (or earlier).

Better earlier (I plan to get some more kmemleak patches into
linux-next).

> hex dump prints not more than HEX_MAX_LINES lines by HEX_ROW_SIZE (16 or 32) bytes.
> ( min(object->size, HEX_MAX_LINES * HEX_ROW_SIZE) ).
> 
> Example (HEX_ROW_SIZE 16):
> 
> unreferenced object 0xf68b59b8 (size 32):
>   comm "swapper", pid 1, jiffies 4294877610
>   hex dump (first 32 bytes):
>     70 6e 70 20 30 30 3a 30 31 00 5a 5a 5a 5a 5a 5a  pnp 00:01.ZZZZZZ
>     5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a a5  ZZZZZZZZZZZZZZZ.

That's my preferred as I do not want to go beyond column 80.

> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 5063873..65c5d74 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -160,6 +160,15 @@ struct kmemleak_object {
>  /* flag set to not scan the object */
>  #define OBJECT_NO_SCAN         (1 << 2)
> 
> +/* number of bytes to print per line; must be 16 or 32 */
> +#define HEX_ROW_SIZE           32

16 here.

> +/* number of bytes to print at a time (1, 2, 4, 8) */
> +#define HEX_GROUP_SIZE         1
> +/* include ASCII after the hex output */
> +#define HEX_ASCII              1
> +/* max number of lines to be printed */
> +#define HEX_MAX_LINES          2
> +
>  /* the list of all allocated objects */
>  static LIST_HEAD(object_list);
>  /* the list of gray-colored objects (see color_gray comment below) */
> @@ -181,6 +190,8 @@ static atomic_t kmemleak_initialized = ATOMIC_INIT(0);
>  static atomic_t kmemleak_early_log = ATOMIC_INIT(1);
>  /* set if a fata kmemleak error has occurred */
>  static atomic_t kmemleak_error = ATOMIC_INIT(0);
> +/* set if hex dump should be printed */
> +static atomic_t kmemleak_hex_dump = ATOMIC_INIT(1);
[...]
> @@ -303,6 +343,11 @@ static void print_unreferenced(struct seq_file *seq,
>                    object->pointer, object->size);
>         seq_printf(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
>                    object->comm, object->pid, object->jiffies);
> +
> +       /* check whether hex dump should be printed */
> +       if (atomic_read(&kmemleak_hex_dump))
> +               hex_dump_object(seq, object);

No need for this check, just leave it in all cases (as we now only read
the reports via the debug/kmemleak file.

> @@ -1269,6 +1314,10 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
>                 start_scan_thread();
>         else if (strncmp(buf, "scan=off", 8) == 0)
>                 stop_scan_thread();
> +       else if (strncmp(buf, "hexdump=on", 10) == 0)
> +               atomic_set(&kmemleak_hex_dump, 1);
> +       else if (strncmp(buf, "hexdump=off", 11) == 0)
> +               atomic_set(&kmemleak_hex_dump, 0);

Same here.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
