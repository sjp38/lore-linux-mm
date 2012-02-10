Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id CF0D36B002C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:45:15 -0500 (EST)
Received: by eekc13 with SMTP id c13so1225064eek.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:45:14 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are
 page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
Date: Fri, 10 Feb 2012 20:45:12 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9hahmw23l0zgt@mpn-glaptop>
In-Reply-To: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Dan Smith <danms@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 10 Feb 2012 20:39:56 +0100, Dan Smith <danms@us.ibm.com> wrote:
> The inner function walk_pte_range() increments "addr" by PAGE_SIZE aft=
er

Commit message says about walk_pte_range() but commit changes walk_page_=
range().

> each pte is processed, and only exits the loop if the result is equal =
to
> "end". Current, if either (or both of) the starting or ending addresse=
s

So why not change the condition to addr < end?

> passed to walk_page_range() are not page-aligned, then we will never
> satisfy that exit condition and begin calling the pte_entry handler wi=
th
> bad data.
>
> To be sure that we will land in the right spot, this patch checks that=

> both "addr" and "end" are page-aligned in walk_page_range() before sta=
rting
> the traversal.
>
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/pagewalk.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 2f5cf10..9242bfc 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -196,6 +196,8 @@ int walk_page_range(unsigned long addr, unsigned l=
ong end,
>  	if (addr >=3D end)
>  		return err;
>+	VM_BUG_ON((addr & ~PAGE_MASK) || (end & ~PAGE_MASK));
> +
>  	if (!walk->mm)
>  		return -EINVAL;
>


-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
