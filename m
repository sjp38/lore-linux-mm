Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id CA6A46B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:36:26 -0400 (EDT)
Received: by igin14 with SMTP id n14so61653618igi.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:36:26 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id yv5si25920546icb.22.2015.06.25.11.36.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 11:36:26 -0700 (PDT)
Received: by igblr2 with SMTP id lr2so61521874igb.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:36:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150625114819.GA20478@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
	<20150608174551.GA27558@gmail.com>
	<20150609084739.GQ26425@suse.de>
	<20150609103231.GA11026@gmail.com>
	<20150609112055.GS26425@suse.de>
	<20150609124328.GA23066@gmail.com>
	<5577078B.2000503@intel.com>
	<20150621202231.GB6766@node.dhcp.inet.fi>
	<20150625114819.GA20478@gmail.com>
Date: Thu, 25 Jun 2015 11:36:25 -0700
Message-ID: <CA+55aFykFDZBEP+fBeqF85jSVuhWVjL5SW_22FTCMrCeoihauw@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=001a113feefca6105105195be6b2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, H Peter Anvin <hpa@zytor.com>, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

--001a113feefca6105105195be6b2
Content-Type: text/plain; charset=UTF-8

On Jun 25, 2015 04:48, "Ingo Molnar" <mingo@kernel.org> wrote:
>
>  - 1x, 2x, 3x, 4x means up to 4 adjacent 4K vmalloc()-ed pages are
accessed, the
>    first byte in each

So that test is a bit unfair. From previous timing of Intel TLB fills, I
can tell you that Intel is particularly good at doing adjacent entries.

That's independent of the fact that page tables have very good locality (if
they are the radix tree type - the hashed page tables that ppc uses are
shit). So when filling adjacent entries, you take the cache misses for the
page tables only once, but even aside from that, Intel send to do
particularly well at the "next page" TLB fill case

Now, I think that's a reasonably common case, and I'm not saying that it's
unfair to compare for that reason, but it does highlight the good case for
TLB walking.

So I would suggest you highlight the bad case too: use invlpg to invalidate
*one* TLB entry, and then walk four non-adjacent entries. And compare
*that* to the full TLB flush.

Now, I happen to still believe in the full flush, but let's not pick
benchmarks that might not show the advantages of the finer granularity.

        Linus

--001a113feefca6105105195be6b2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jun 25, 2015 04:48, &quot;Ingo Molnar&quot; &lt;<a href=3D"mailto:mingo@=
kernel.org">mingo@kernel.org</a>&gt; wrote:<br>
&gt;<br>
&gt; =C2=A0- 1x, 2x, 3x, 4x means up to 4 adjacent 4K vmalloc()-ed pages ar=
e accessed, the<br>
&gt; =C2=A0 =C2=A0first byte in each</p>
<p dir=3D"ltr">So that test is a bit unfair. From previous timing of Intel =
TLB fills, I can tell you that Intel is particularly good at doing adjacent=
 entries.</p>
<p dir=3D"ltr">That&#39;s independent of the fact that page tables have ver=
y good locality (if they are the radix tree type - the hashed page tables t=
hat ppc uses are shit). So when filling adjacent entries, you take the cach=
e misses for the page tables only once, but even aside from that, Intel sen=
d to do particularly well at the &quot;next page&quot; TLB fill case </p>
<p dir=3D"ltr">Now, I think that&#39;s a reasonably common case, and I&#39;=
m not saying that it&#39;s unfair to compare for that reason, but it does h=
ighlight the good case for TLB walking. </p>
<p dir=3D"ltr">So I would suggest you highlight the bad case too: use invlp=
g to invalidate *one* TLB entry, and then walk four non-adjacent entries. A=
nd compare *that* to the full TLB flush.</p>
<p dir=3D"ltr">Now, I happen to still believe in the full flush, but let&#3=
9;s not pick benchmarks that might not show the advantages of the finer gra=
nularity.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>

--001a113feefca6105105195be6b2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
