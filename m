Received: by rv-out-0910.google.com with SMTP id f1so670812rvb.26
        for <linux-mm@kvack.org>; Fri, 01 Feb 2008 00:24:17 -0800 (PST)
Message-ID: <3fd7d7a70802010024q22b4d179mf56e6d4b60e4f574@mail.gmail.com>
Date: Fri, 1 Feb 2008 17:24:17 +0900
From: "Kenichi Okuyama" <kenichi.okuyama@gmail.com>
Subject: Re: [patch] NULL pointer check for vma->vm_mm
In-Reply-To: <20080131235544.346b938a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <3fd7d7a70801312339p2a142096p83ed286c81379728@mail.gmail.com>
	 <20080131235544.346b938a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dear Andrew, all,

First of all, thank you for looking at the patch.

I do agree that if mm is NULL, system will call Oops anyway.
However, since it's oops, it does not stop the system, nor call kdump.

By calling BUG_ON(), it'll gives us chance of calling kdump at the first chance.

Since this is very rare to happen, I thought we should capture the incident
whenever possible. On other hand, because BUG_ON macro is very light,
I thought this will not harm any performance...

Forgive me in advance if I was wrong.
I still think checking mm with BUG_ON here is better than counting on Oops.

best regards,



2008/2/1, Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 1 Feb 2008 16:39:07 +0900 "Kenichi Okuyama" <kenichi.okuyama@gmail.com> wrote:
>
> > Dear all,
> >
> > I was looking at the ./mm/rmap.c .. I found that, in function
> > "page_referenced_one()",
> >    struct mm_struct *mm = vma->vm_mm;
> > was being refererred without NULL check.
> >
> > Though I do agree that this works for most of the cases, I thought it
> > is better to add
> > BUG_ON() for case of mm being NULL.
> >
> > attached is the patch for this
>
> If we dereference NULL then the kernel will display basically the same
> information as would a BUG, and it takes the same action.  So adding a
> BUG_ON here really doesn't gain us anything.
>
> Also, I think vma->vm_mm == 0 is not a valid state, so this just shouldn't
> happen - the code is OK to assume that a particular invariant is being
> honoured.
>
>


-- 
奥山　健一(Kenichi Okuyama) [煤背会: No. 0x00000001]
URL: http://www.dd.iij4u.or.jp/~okuyamak/
     http://developer.osdl.jp/projects/doubt/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
