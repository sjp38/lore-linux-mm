Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3A7846B006C
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 13:37:17 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id k14so4874986oag.39
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 10:37:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <515FF3CC.80106@gmail.com>
References: <515FF3CC.80106@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 6 Apr 2013 13:36:56 -0400
Message-ID: <CAHGf_=p=U8urX0NF4M0=brffLhvWYU-6kcA2+sBWa8f1JFGkzw@mail.gmail.com>
Subject: Re: [PATCH 4/4] fsfreeze: avoid to return zero in __get_user_pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, Mike Snitzer <snitzer@redhat.com>, Alasdair G Kergon <agk@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Sat, Apr 6, 2013 at 6:07 AM, Marco Stornelli
<marco.stornelli@gmail.com> wrote:
> In case of VM_FAULT_RETRY, __get_user_pages returns the number
> of pages alredy gotten, but there isn't a check if this number is
> zero. Instead, we have to return a proper error code so we can avoid
> a possible extra call of __get_user_pages. There are several
> places where get_user_pages is called inside a loop until all the
> pages requested are gotten or an error code is returned.
>
> Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
> ---
>  mm/memory.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 494526a..cca14ed 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1858,7 +1858,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>                                 if (ret & VM_FAULT_RETRY) {
>                                         if (nonblocking)
>                                                 *nonblocking = 0;
> -                                       return i;
> +                                       return i ? i : -ERESTARTSYS;

nonblock argument is only used from __mm_populate() and it expect
__get_user_pages() return 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
