Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D868F6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 04:00:57 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so291975fga.8
        for <linux-mm@kvack.org>; Mon, 22 Mar 2010 01:00:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100322005610.5dfa70b1.akpm@linux-foundation.org>
References: <20100322053937.GA17637@laptop>
	 <20100322005610.5dfa70b1.akpm@linux-foundation.org>
Date: Mon, 22 Mar 2010 10:00:54 +0200
Message-ID: <84144f021003220100r29ee1ff2x11a66531e0104167@mail.gmail.com>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 6:56 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 22 Mar 2010 16:39:37 +1100 Nick Piggin <npiggin@suse.de> wrote:
>
>> It's ugly and lazy that we do these default aops in case it has not
>> been filled in by the filesystem.
>>
>> A NULL operation should always mean either: we don't support the
>> operation; we don't require any action; or a bug in the filesystem,
>> depending on the context.
>>
>> In practice, if we get rid of these fallbacks, it will be clearer
>> what operations are used by a given address_space_operations struct,
>> reduce branches, reduce #if BLOCK ifdefs, and should allow us to get
>> rid of all the buffer_head knowledge from core mm and fs code.
>
> I guess this is one way of waking people up.
>
> What happens is that hundreds of bug reports land in my inbox and I get
> to route them to various maintainers, most of whom don't exist, so
> warnings keep on landing in my inbox. =A0Please send a mailing address fo=
r
> my invoices.
>
> It would be more practical, more successful and quicker to hunt down
> the miscreants and send them rude emails. =A0Plus it would save you
> money.
>
>> We could add a patch like this which spits out a recipe for how to fix
>> up filesystems and get them all converted quite easily.
>>
>> ...
>>
>> @@ -40,8 +40,14 @@ void do_invalidatepage(struct page *page
>> =A0 =A0 =A0 void (*invalidatepage)(struct page *, unsigned long);
>> =A0 =A0 =A0 invalidatepage =3D page->mapping->a_ops->invalidatepage;
>> =A0#ifdef CONFIG_BLOCK
>> - =A0 =A0 if (!invalidatepage)
>> + =A0 =A0 if (!invalidatepage) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 static bool warned =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!warned) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 warned =3D true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_symbol("address_space_op=
erations %s missing invalidatepage method. Use block_invalidatepage.\n", (u=
nsigned long)page->mapping->a_ops);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 invalidatepage =3D block_invalidatepage;
>> + =A0 =A0 }
>
> erk, I realise 80 cols can be a pain, but 165 cols is just out of
> bounds. =A0Why not
>
> =A0 =A0 =A0 =A0/* this fs should use block_invalidatepage() */
> =A0 =A0 =A0 =A0WARN_ON_ONCE(!invalidatepage);

/me gets his paint bucket...

How about

    WARN_ONCE(!invalidatepage, "this fs should use block_invalidatepage()")

                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
