Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA576B008A
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 07:06:06 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oAEC5wnO024710
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 04:05:58 -0800
Received: from qyk38 (qyk38.prod.google.com [10.241.83.166])
	by hpaq2.eem.corp.google.com with ESMTP id oAEC5uSr008636
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 04:05:57 -0800
Received: by qyk38 with SMTP id 38so2552144qyk.9
        for <linux-mm@kvack.org>; Sun, 14 Nov 2010 04:05:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289379628-14044-2-git-send-email-lliubbo@gmail.com>
References: <1289379628-14044-1-git-send-email-lliubbo@gmail.com>
	<1289379628-14044-2-git-send-email-lliubbo@gmail.com>
Date: Sun, 14 Nov 2010 04:05:56 -0800
Message-ID: <AANLkTikmg_Uiu4bP-U05wbCJnPo5Xt=qxSB+45Oq=5en@mail.gmail.com>
Subject: Re: [PATCH 2/2] clean up set_page_dirty()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 1:00 AM, Bob Liu <lliubbo@gmail.com> wrote:
> Use TestSetPageDirty() to clean up set_page_dirty().
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> =A0mm/page-writeback.c | =A0 =A07 ++-----
> =A01 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index e8f5f06..da86224 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1268,11 +1268,8 @@ int set_page_dirty(struct page *page)
> =A0#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return (*spd)(page);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 if (!PageDirty(page)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!TestSetPageDirty(page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 return !TestSetPageDirty(page);
> =A0}
> =A0EXPORT_SYMBOL(set_page_dirty);

TestSetPageDirty compiles to a locked bts instruction (on x86). This
will acquire the cache line for exclusive access, even when the bit is
already set. I think this is why we have an extra if
(!PageDirty(page)) test - we don't want to cause cache coherency
overhead if the page is already dirty.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
