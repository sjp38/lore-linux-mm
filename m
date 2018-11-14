Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73A136B000A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:32:25 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id j69-v6so13916125ywb.19
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:32:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2-v6sor10482567ybq.168.2018.11.14.15.32.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 15:32:24 -0800 (PST)
Received: from mail-yb1-f171.google.com (mail-yb1-f171.google.com. [209.85.219.171])
        by smtp.gmail.com with ESMTPSA id u4sm4957796ywu.92.2018.11.14.15.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 15:32:22 -0800 (PST)
Received: by mail-yb1-f171.google.com with SMTP id p144-v6so7620070yba.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:32:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 14 Nov 2018 17:32:21 -0600
Message-ID: <CAGXu5j+pRq1m=UNtkz0U-pvsdf=zT5is0LWdk77QkgGfxK_mGw@mail.gmail.com>
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Isaac J. Manjarres" <isaacm@codeaurora.org>
Cc: Chris von Recklinghausen <crecklin@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sodagudi Prasad <psodagud@codeaurora.org>, tsoni@codeaurora.org, "# 3.4.x" <stable@vger.kernel.org>

On Tue, Nov 13, 2018 at 6:51 PM, Isaac J. Manjarres
<isaacm@codeaurora.org> wrote:
> Currently, when checking to see if accessing n bytes starting at
> address "ptr" will cause a wraparound in the memory addresses,
> the check in check_bogus_address() adds an extra byte, which is
> incorrect, as the range of addresses that will be accessed is
> [ptr, ptr + (n - 1)].
>
> This can lead to incorrectly detecting a wraparound in the
> memory address, when trying to read 4 KB from memory that is
> mapped to the the last possible page in the virtual address
> space, when in fact, accessing that range of memory would not
> cause a wraparound to occur.

I'm kind of surprised anything is using the -4K memory range -- this
is ERR_PTR() area and I'd expect there to be an explicit unallocated
memory hole here.

>
> Use the memory range that will actually be accessed when
> considering if accessing a certain amount of bytes will cause
> the memory address to wrap around.
>
> Change-Id: I2563a5988e41122727ede17180f365e999b953e6
> Fixes: f5509cc18daa ("mm: Hardened usercopy")
> Co-Developed-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Signed-off-by: Isaac J. Manjarres <isaacm@codeaurora.org>
> Cc: stable@vger.kernel.org

Regardless, I'll take it in my tree if akpm doesn't grab it first. :)

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/usercopy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 852eb4e..0293645 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -151,7 +151,7 @@ static inline void check_bogus_address(const unsigned long ptr, unsigned long n,
>                                        bool to_user)
>  {
>         /* Reject if object wraps past end of memory. */
> -       if (ptr + n < ptr)
> +       if (ptr + (n - 1) < ptr)
>                 usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
>
>         /* Reject if NULL or ZERO-allocation. */
> --
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project
>



-- 
Kees Cook
