Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 254E36B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 00:39:06 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id xn12so6389287obc.6
        for <linux-mm@kvack.org>; Mon, 19 Aug 2013 21:39:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130819231836.GD14369@redhat.com>
References: <20130807055157.GA32278@redhat.com>
	<CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
	<20130807153030.GA25515@redhat.com>
	<CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
	<20130819231836.GD14369@redhat.com>
Date: Tue, 20 Aug 2013 12:39:05 +0800
Message-ID: <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 20, 2013 at 7:18 AM, Dave Jones <davej@redhat.com> wrote:
>
> btw, anyone have thoughts on a patch something like below ?

And another(sorry if message is reformatted by the mail agent,
and it took my an hour to get the agent back to the correct format but failed,
and thanks a lot for any howto send plain text message).

Hillf

--- a/mm/memory.c Wed Aug  7 16:29:34 2013
+++ b/mm/memory.c Tue Aug 20 11:13:06 2013
@@ -933,8 +933,10 @@ again:
  if (progress >= 32) {
  progress = 0;
  if (need_resched() ||
-    spin_needbreak(src_ptl) || spin_needbreak(dst_ptl))
+    spin_needbreak(src_ptl) || spin_needbreak(dst_ptl)) {
+     BUG_ON(entry.val);
  break;
+ }
  }
  if (pte_none(*src_pte)) {
  progress++;
--


> It's really annoying to debug stuff like this and have to walk
> over to the machine and reboot it by hand after it wedges during swapoff.
>
>         Dave
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6cf2e60..bbb1192 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1587,6 +1587,10 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>         if (!capable(CAP_SYS_ADMIN))
>                 return -EPERM;
>
> +       /* If we have hit memory corruption, we could hang during swapoff, so don't even try. */
> +       if (test_taint(TAINT_BAD_PAGE))
> +               return -EINVAL;
> +
>         BUG_ON(!current->mm);
>
>         pathname = getname(specialfile);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
