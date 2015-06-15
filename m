Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8329A6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:19:08 -0400 (EDT)
Received: by igbos3 with SMTP id os3so25596465igb.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:19:08 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id f6si8767661igt.23.2015.06.15.11.19.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 11:19:08 -0700 (PDT)
Received: by iesa3 with SMTP id a3so68155620ies.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:19:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434388931-24487-6-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
	<1434388931-24487-6-git-send-email-aarcange@redhat.com>
Date: Mon, 15 Jun 2015 08:19:07 -1000
Message-ID: <CA+55aFxD8hakE9SjhAD1_vJ9PATK+90k7yHQ2cENqGqK8r3QhQ@mail.gmail.com>
Subject: Re: [PATCH 5/7] userfaultfd: switch to exclusive wakeup for blocking reads
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=90e6ba6e8ade5dc9700518927e7c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, zhang.zhanghailiang@huawei.com, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Feiner <pfeiner@google.com>, Mel Gorman <mgorman@suse.de>, kvm@vger.kernel.org

--90e6ba6e8ade5dc9700518927e7c
Content-Type: text/plain; charset=UTF-8

On Jun 15, 2015 7:22 AM, "Andrea Arcangeli" <aarcange@redhat.com> wrote:
>
> Blocking reads can easily use exclusive wakeups. Poll in theory could
> too but there's no poll_wait_exclusive in common code yet.

NAK.

Tie while commit message is crap, and so us the comment

No, your really cannot "easily use exclusive waits", and no, using them for
polling isn't about a lack of interface, it's about the fact that it would
be buggy shit.

What if the process doing the polling never doors anything with the end
result? Maybe it meant to, but it got killed before it could? Are you going
to leave everybody else blocked, even though there are pending events?

The same us try of read() too. What if the reader only reads party of the
message? The wake didn't wake anybody else, so now people are (again)
blocked despite there being data.

So no, exclusive waiting is never "simple". You have to 100% guarantee that
you will consume all the data that caused the wake event (or perhaps wake
the next person up if you don't).

    Linus

--90e6ba6e8ade5dc9700518927e7c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jun 15, 2015 7:22 AM, &quot;Andrea Arcangeli&quot; &lt;<a href=3D"mailto=
:aarcange@redhat.com">aarcange@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Blocking reads can easily use exclusive wakeups. Poll in theory could<=
br>
&gt; too but there&#39;s no poll_wait_exclusive in common code yet.</p>
<p dir=3D"ltr">NAK.</p>
<p dir=3D"ltr">Tie while commit message is crap, and so us the comment </p>
<p dir=3D"ltr">No, your really cannot &quot;easily use exclusive waits&quot=
;, and no, using them for polling isn&#39;t about a lack of interface, it&#=
39;s about the fact that it would be buggy shit.</p>
<p dir=3D"ltr">What if the process doing the polling never doors anything w=
ith the end result? Maybe it meant to, but it got killed before it could? A=
re you going to leave everybody else blocked, even though there are pending=
 events?</p>
<p dir=3D"ltr">The same us try of read() too. What if the reader only reads=
 party of the message? The wake didn&#39;t wake anybody else, so now people=
 are (again) blocked despite there being data.</p>
<p dir=3D"ltr">So no, exclusive waiting is never &quot;simple&quot;. You ha=
ve to 100% guarantee that you will consume all the data that caused the wak=
e event (or perhaps wake the next person up if you don&#39;t).</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0 Linus</p>

--90e6ba6e8ade5dc9700518927e7c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
