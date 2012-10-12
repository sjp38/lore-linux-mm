Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E94F36B0068
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 08:37:44 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so1949726wey.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 05:37:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1349346078-24874-2-git-send-email-anton.vorontsov@linaro.org>
References: <20121004102013.GA23284@lizard>
	<1349346078-24874-2-git-send-email-anton.vorontsov@linaro.org>
Date: Fri, 12 Oct 2012 15:37:43 +0300
Message-ID: <CAOJsxLFW3WbBDdFhuJDwUxvGVfsy_Tg8SpR4pxTWAcfQ+LG0UQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmevent: Factor vmevent_match_attr() out of vmevent_match()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Thu, Oct 4, 2012 at 1:21 PM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> Soon we'll use this new function for other code; plus this makes code less
> indented.
>
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> ---
>  mm/vmevent.c | 107 +++++++++++++++++++++++++++++++----------------------------
>  1 file changed, 57 insertions(+), 50 deletions(-)
>
> diff --git a/mm/vmevent.c b/mm/vmevent.c
> index 39ef786..d434c11 100644
> --- a/mm/vmevent.c
> +++ b/mm/vmevent.c
> @@ -77,6 +77,59 @@ enum {
>         VMEVENT_ATTR_STATE_VALUE_WAS_GT = (1UL << 31),
>  };
>
> +static bool vmevent_match_attr(struct vmevent_attr *attr, u64 value)
> +{
> +       u32 state = attr->state;
> +       bool attr_lt = state & VMEVENT_ATTR_STATE_VALUE_LT;
> +       bool attr_gt = state & VMEVENT_ATTR_STATE_VALUE_GT;
> +       bool attr_eq = state & VMEVENT_ATTR_STATE_VALUE_EQ;
> +       bool edge = state & VMEVENT_ATTR_STATE_EDGE_TRIGGER;
> +       u32 was_lt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_LT;
> +       u32 was_gt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_GT;
> +       bool lt = value < attr->value;
> +       bool gt = value > attr->value;
> +       bool eq = value == attr->value;
> +       bool was_lt = state & was_lt_mask;
> +       bool was_gt = state & was_gt_mask;

[snip]

So I merged this patch but vmevent_match_attr() is still too ugly for
words. It really could use some serious cleanups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
