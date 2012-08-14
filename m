Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id B0D206B002B
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 11:07:00 -0400 (EDT)
Received: by qady1 with SMTP id y1so453806qad.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 08:06:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013925a326f6-c47d16cb-5c67-4a28-ab5c-e0c3c9fbf610-000000@email.amazonses.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
	<1344955130-29478-2-git-send-email-elezegarcia@gmail.com>
	<0000013925a326f6-c47d16cb-5c67-4a28-ab5c-e0c3c9fbf610-000000@email.amazonses.com>
Date: Tue, 14 Aug 2012 12:06:59 -0300
Message-ID: <CALF0-+VNfZ07jAiyKBGzrRGOz5QDy1ybGRmXL9JyXGTJAyHkBA@mail.gmail.com>
Subject: Re: [RFC/PATCH 2/2] mm, slob: Save real allocated size in page->private
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

Hi Christoph,

Thanks for your comments.

On Tue, Aug 14, 2012 at 11:56 AM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 14 Aug 2012, Ezequiel Garcia wrote:
>
>> As documented in slob.c header, page->private field is used to return
>> accurately the allocated size, through ksize().
>> Therefore, if one allocates a contiguous set of pages the available size
>> is PAGE_SIZE << order, instead of the requested size.
>
> I would prefer if you would remove this strange feature from slob. The
> ksize for a !PageSlab() "slab" page is always PAGE_SIZE << compound_order(page).
> There is no need to use page->private here. It is a bad practice to not
> mark a page as a slab page but then use fields for special purposes.
>

Mmm, I see. Sounds sensible.
Fortunately I don't have to squeeze my brain thinking,
since I have a nice example of this in slub's ksize().

        if (unlikely(!PageSlab(page))) {
                WARN_ON(!PageCompound(page));
                return PAGE_SIZE << compound_order(page);
        }

I'll resend this patch alone with implementing something like
it and removing page->private usage.

Thanks again!
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
