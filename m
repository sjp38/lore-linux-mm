Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2AF6B0062
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 06:40:36 -0500 (EST)
Received: by iaqq3 with SMTP id q3so3223321iaq.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 03:40:29 -0800 (PST)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: KSM: numa awareness sysfs knob
Date: Thu, 1 Dec 2011 19:40:18 +0800
References: <1322649446-11437-1-git-send-email-pholasek@redhat.com> <20111130154719.57154fdd.akpm@linux-foundation.org> <20111201101640.GA2156@dhcp-27-244.brq.redhat.com>
In-Reply-To: <20111201101640.GA2156@dhcp-27-244.brq.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/alternative;
  boundary="Boundary-01=_ie21OXi9uUKmcfb"
Content-Transfer-Encoding: 7bit
Message-Id: <201112011940.19022.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

--Boundary-01=_ie21OXi9uUKmcfb
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thursday 01 December 2011 18:16:40 Petr Holasek wrote:
> On Wed, 30 Nov 2011, Andrew Morton wrote:
> 
> > Date: Wed, 30 Nov 2011 15:47:19 -0800
> > From: Andrew Morton <akpm@linux-foundation.org>
> > To: Petr Holasek <pholasek@redhat.com>
> > Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli
> >  <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
> >  Anton Arapov <anton@redhat.com>
> > Subject: Re: [PATCH] [RFC] KSM: numa awareness sysfs knob
> > 
> > On Wed, 30 Nov 2011 11:37:26 +0100
> > Petr Holasek <pholasek@redhat.com> wrote:
> > 
> > > Introduce a new sysfs knob /sys/kernel/mm/ksm/max_node_dist, whose
> > > value will be used as the limitation for node distance of merged pages.
> > > 
> > 
> > The changelog doesn't really describe why you think Linux needs this
> > feature?  What's the reasoning?  Use cases?  What value does it provide?
> 
> Typical use-case could be a lot of KVM guests on NUMA machine and cpus from
> more distant nodes would have significant increase of access latency to the
> merged ksm page. I chose sysfs knob for higher scalability.

Seems this consideration for NUMA is sound. 

> 
> > 
> > > index b392e49..b882140 100644
> > > --- a/Documentation/vm/ksm.txt
> > > +++ b/Documentation/vm/ksm.txt
> > > @@ -58,6 +58,10 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
> > >                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
> > >                     Default: 20 (chosen for demonstration purposes)
> > >  
> > > +max_node_dist    - maximum node distance between two pages which could be
> > > +                   merged.
> > > +                   Default: 255 (without any limitations)
> > 
> > And this doesn't explain to our users why they might want to alter it,
> > and what effects they would see from doing so.  Maybe that's obvious to
> > them...
> 
> Now I can't figure out more extensive description of this feature, but we
> could explain it deeply, of course.

However, if we don't know what the number fed into this knob really means, 
seems nobody would think of using this knob...

Then why not make this NUMA feature automatically adjusted by some algorithm
instread of dropping it to userland?

BTW, the algrothim you already include in this patch seems unstable itself:

Suppose we have three duplicated pages in order: Page_a, Page_b, Page_c with 
distance(Page_a, Page_b) == distance(Page_b, Page_c) == 3, 
but distance(Page_a, Page_c) == 6 and if max_node_dist == 3, 
a stable algorithm should result in Page_a and Page_c being merged to Page_b,
independent of the order these pages get scanned. 

But with your patch, if ksmd goes Page_b --> Page_c --> Page_a, will it 
result in Page_b being merged to Page_c but Page_a not merged since its 
distance to Page_c is 6?

It may easy to further deduce that maybe a worst case(or even many cases?) 
for your patch will get many many could-be-merged pages not merged simply 
because of the sequence they are scanned.

The problem you plan to solve maybe worthwhile, but it may also be much more
complex than you expected ;-)
  

BR,

Nai

--Boundary-01=_ie21OXi9uUKmcfb
Content-Type: text/html;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html><head><meta name="qrichtext" content="1" /><style type="text/css">
p, li { white-space: pre-wrap; }
</style></head><body style=" font-family:'DejaVu Sans Mono'; font-size:9.5pt; font-weight:400; font-style:normal;">
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">On Thursday 01 December 2011 18:16:40 Petr Holasek wrote:</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; On Wed, 30 Nov 2011, Andrew Morton wrote:</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; Date: Wed, 30 Nov 2011 15:47:19 -0800</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; From: Andrew Morton &lt;akpm@linux-foundation.org&gt;</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; To: Petr Holasek &lt;pholasek@redhat.com&gt;</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; Cc: Hugh Dickins &lt;hughd@google.com&gt;, Andrea Arcangeli</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt;  &lt;aarcange@redhat.com&gt;, linux-kernel@vger.kernel.org, linux-mm@kvack.org,</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt;  Anton Arapov &lt;anton@redhat.com&gt;</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; Subject: Re: [PATCH] [RFC] KSM: numa awareness sysfs knob</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; On Wed, 30 Nov 2011 11:37:26 +0100</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; Petr Holasek &lt;pholasek@redhat.com&gt; wrote:</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; Introduce a new sysfs knob /sys/kernel/mm/ksm/max_node_dist, whose</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; value will be used as the limitation for node distance of merged pages.</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; The changelog doesn't really describe why you think Linux needs this</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; feature?  What's the reasoning?  Use cases?  What value does it provide?</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; Typical use-case could be a lot of KVM guests on NUMA machine and cpus from</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; more distant nodes would have significant increase of access latency to the</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; merged ksm page. I chose sysfs knob for higher scalability.</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">Seems this consideration for NUMA is sound. </p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; index b392e49..b882140 100644</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; --- a/Documentation/vm/ksm.txt</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; +++ b/Documentation/vm/ksm.txt</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; @@ -58,6 +58,10 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt;                     e.g. &quot;echo 20 &gt; /sys/kernel/mm/ksm/sleep_millisecs&quot;</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt;                     Default: 20 (chosen for demonstration purposes)</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt;  </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; +max_node_dist    - maximum node distance between two pages which could be</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; +                   merged.</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; &gt; +                   Default: 255 (without any limitations)</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; And this doesn't explain to our users why they might want to alter it,</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; and what effects they would see from doing so.  Maybe that's obvious to</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; &gt; them...</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; Now I can't figure out more extensive description of this feature, but we</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; could explain it deeply, of course.</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">However, if we don't know what the number fed into this knob really means, </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">seems nobody would think of using this knob...</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">Then why not make this NUMA feature automatically adjusted by some algorithm</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">instread of dropping it to userland?</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">BTW, the algrothim you already include in this patch seems unstable itself:</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">Suppose we have three duplicated pages in order: Page_a, Page_b, Page_c with </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">distance(Page_a, Page_b) == distance(Page_b, Page_c) == 3, </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">but distance(Page_a, Page_c) == 6 and if max_node_dist == 3, </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">a stable algorithm should result in Page_a and Page_c being merged to Page_b,</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">independent of the order these pages get scanned. </p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">But with your patch, if ksmd goes Page_b --&gt; Page_c --&gt; Page_a, will it </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">result in Page_b being merged to Page_c but Page_a not merged since its </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">distance to Page_c is 6?</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">It may easy to further deduce that maybe a worst case(or even many cases?) </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">for your patch will get many many could-be-merged pages not merged simply </p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">because of the sequence they are scanned.</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">The problem you plan to solve maybe worthwhile, but it may also be much more</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">complex than you expected ;-)</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">  </p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">BR,</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;"><br /></p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">Nai</p></body></html>
--Boundary-01=_ie21OXi9uUKmcfb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
