Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 829AA6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 04:57:01 -0400 (EDT)
Received: by oip136 with SMTP id 136so5652481oip.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:57:01 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id m71si4013905oig.104.2015.08.12.01.57.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 01:57:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 5/5] mm/hwpoison: replace most of put_page in memory
 error handling by put_hwpoison_page
Date: Wed, 12 Aug 2015 08:55:26 +0000
Message-ID: <20150812085525.GD32192@hori1.linux.bs1.fc.nec.co.jp>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP12740A47B6EBB7DF2F12A9280700@phx.gbl>
In-Reply-To: <BLU436-SMTP12740A47B6EBB7DF2F12A9280700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <843CC0B960D5994BBFBAE8B5AC12A0CB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 07:28:23PM +0800, Wanpeng Li wrote:
> Replace most of put_page in memory error handling by put_hwpoison_page,
> except the ones at the front of soft_offline_page since the page maybe
> THP page and the get refcount in madvise_hwpoison is against the single
> 4KB page instead of the logic in get_hwpoison_page.
>
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>

# Sorry for my late response.

If I read correctly, get_user_pages_fast() (called by madvise_hwpoison)
for a THP tail page takes a refcount from each of head and tail page.
gup_huge_pmd() does this in the fast path, and get_page_foll() does this
in the slow path (maybe via the following code path)

  get_user_pages_unlocked
    __get_user_pages_unlocked
      __get_user_pages_locked
        __get_user_pages
          follow_page_mask
            follow_trans_huge_pmd (with FOLL_GET set)
              get_page_foll

So this should be equivalent to what get_hwpoison_page() does for thp pages
with regard to refcounting.

And I'm expecting that a refcount taken by get_hwpoison_page() is released
by put_hwpoison_page() even if the page's status is changed during error
handling (the typical (or only?) case is successful thp split.)

So I think you can apply put_hwpoison_page() for 3 more callsites in
mm/memory-failure.c.
 - MF_MSG_POISONED_HUGE case
 - "soft offline: %#lx page already poisoned" case (you mentioned above)
 - "soft offline: %#lx: failed to split THP" case (you mentioned above)

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
