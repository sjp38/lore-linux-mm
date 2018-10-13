Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 390616B000A
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 13:05:23 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id h21-v6so10476966oib.16
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 10:05:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j187-v6sor2238437oif.166.2018.10.13.10.05.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Oct 2018 10:05:22 -0700 (PDT)
MIME-Version: 1.0
References: <1539447319-5383-1-git-send-email-penghao122@sina.com.cn>
In-Reply-To: <1539447319-5383-1-git-send-email-penghao122@sina.com.cn>
From: Pavel Tatashin <pasha.tatashin@gmail.com>
Date: Sat, 13 Oct 2018 13:04:45 -0400
Message-ID: <CAGM2reYqEpY9KbMDU6uSaCuzsyN6qcXit930vbWk54PLhvZxZg@mail.gmail.com>
Subject: Re: [PATCH] mm/sparse: remove a check that compare if unsigned
 variable is negative
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penghao122@sina.com.cn
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, pasha.tatashin@oracle.com, osalvador@suse.de, LKML <linux-kernel@vger.kernel.org>, peng.hao2@zte.com.cn

This is incorrect: next_present_section_nr() returns "int" and -1 no
next section, this change would lead to infinite loop.
On Sat, Oct 13, 2018 at 12:16 PM Peng Hao <penghao122@sina.com.cn> wrote:
>
>
> From: Peng Hao <peng.hao2@zte.com.cn>
>
> In all use locations for for_each_present_section_nr, variable
> section_nr is unsigned. It is unnecessary to test if it is negative.
>
> Signed-off-by: Peng Hao <peng.hao2@zte.com.cn>
> ---
>  mm/sparse.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 10b07ee..a6f9f22 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -196,8 +196,7 @@ static inline int next_present_section_nr(int section_nr)
>  }
>  #define for_each_present_section_nr(start, section_nr)         \
>         for (section_nr = next_present_section_nr(start-1);     \
> -            ((section_nr >= 0) &&                              \
> -             (section_nr <= __highest_present_section_nr));    \
> +            section_nr <= __highest_present_section_nr;        \
>              section_nr = next_present_section_nr(section_nr))
>
>  static inline unsigned long first_present_section_nr(void)
> --
> 1.8.3.1
>
>
