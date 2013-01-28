Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 49EAC6B0002
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 08:47:12 -0500 (EST)
Message-ID: <51068155.4020807@redhat.com>
Date: Mon, 28 Jan 2013 14:47:01 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial write
References: <1359333506-13599-1-git-send-email-minchan@kernel.org> <CAOJsxLFg_5uhZsvPmVVC0nnsZLGpkJ0W6mHa=aavmguLGuTTnA@mail.gmail.com> <51065FD4.6090200@redhat.com> <CAOJsxLG=3sWdFkvb++f2ywhs288ozoMXZd_g2WOAgxTqxayY_Q@mail.gmail.com>
In-Reply-To: <CAOJsxLG=3sWdFkvb++f2ywhs288ozoMXZd_g2WOAgxTqxayY_Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, stable@vger.kernel.org

On 01/28/2013 02:26 PM, Pekka Enberg wrote:
> On Mon, Jan 28, 2013 at 1:24 PM, Jerome Marchand <jmarchan@redhat.com> wrote:
>> On 01/28/2013 08:16 AM, Pekka Enberg wrote:
>>> On Mon, Jan 28, 2013 at 2:38 AM, Minchan Kim <minchan@kernel.org> wrote:
>>>> Now zram allocates new page with GFP_KERNEL in zram I/O path
>>>> if IO is partial. Unfortunately, It may cuase deadlock with
>>>
>>> s/cuase/cause/g
>>>
>>>> reclaim path so this patch solves the problem.
>>>
>>> It'd be nice to know about the problem in more detail. I'm also
>>> curious on why you decided on GFP_ATOMIC for the read path and
>>> GFP_NOIO in the write path.
>>
>> This is because we're holding a kmap_atomic page in the read path.
> 
> Okay, so that's about partial *reads* and not even mentioned in the
> changelog, no?
> 
> AFAICT, you could rearrange the code in zram_bvec_read() as follows:
> 
>         if (is_partial_io(bvec))
>                 /* Use  a temporary buffer to decompress the page */
>                 uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
>         else {
>                 uncmem = user_mem = kmap_atomic(page);
>         }
> 
> and avoid the GFP_ATOMIC allocation.
> 

user_mem still has to be mapped in case of partial I/O too. But the
temporary buffer allocation could happen before. The allocation still
would need to be GFP_NOIO to avoid possible deadlocks.

Anyhow, the commit message could definitely be more explicit.

Regards,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
