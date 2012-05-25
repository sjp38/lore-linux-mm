Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3897A6B00EC
	for <linux-mm@kvack.org>; Thu, 24 May 2012 20:24:02 -0400 (EDT)
From: "Olav Haugan" <ohaugan@codeaurora.org>
References: <001c01cd3987$d1a71a50$74f54ef0$%cho@samsung.com> <20120524151231.e3a18ac5.akpm@linux-foundation.org>
In-Reply-To: <20120524151231.e3a18ac5.akpm@linux-foundation.org>
Subject: RE: mm: fix faulty initialization in vmalloc_init()
Date: Thu, 24 May 2012 17:24:01 -0700
Message-ID: <002c01cd3a0c$aef39530$0cdabf90$@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>, 'KyongHo' <pullip.cho@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org

> -----Original Message-----
> On Thu, 24 May 2012 17:32:56 +0900
> KyongHo <pullip.cho@samsung.com> wrote:
> 
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1185,9 +1185,10 @@ void __init vmalloc_init(void)
> >  	/* Import existing vmlist entries. */
> >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> >  		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
 > -		va->flags = tmp->flags | VM_VM_AREA;
> > +		va->flags = VM_VM_AREA;
> 
> This change is a mystery.  Why do we no longer transfer ->flags?

I was actually debugging the same exact issue today. This transfer of flags
actually causes some of the static mapping virtual addresses to be
prematurely freed (before the mapping is removed) because VM_LAZY_FREE gets
"set" if tmp->flags has VM_IOREMAP set. This might cause subsequent
vmalloc/ioremap calls to fail because it might allocate one of the freed
virtual address ranges that aren't unmapped. 

--
Olav Haugan

Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
