Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 366236B02CA
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:07:37 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id f73so168065929ioe.1
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 15:07:37 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id q16si11360387itc.58.2016.12.19.15.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 15:07:36 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id y124so20787827iof.1
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 15:07:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161219225826.F8CB356F@viggo.jf.intel.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Dec 2016 15:07:34 -0800
Message-ID: <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Content-Type: multipart/alternative; boundary=001a113f8e6644b85605440afc18
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, mgorman@techsingularity.net, linux-mm@kvack.org

--001a113f8e6644b85605440afc18
Content-Type: text/plain; charset=UTF-8

On Dec 19, 2016 2:58 PM, "Dave Hansen" <dave.hansen@linux.intel.com> wrote:


This boots in a small VM and on a multi-node NUMA system, but has not
been tested widely.


No, this is wrong.

+wait_queue_head_t *bit_waitqueue(void *word, int bit)
+{
+       const int __maybe_unused nid = page_to_nid(virt_to_page(word));
+
+       return __bit_waitqueue(word, bit, nid);


No can do. Part of the problem with the old coffee was that it did that
virt_to_page() crud. That doesn't work with the virtually mapped stack.

So bit_waitqueue() must not do the page lookup.

Only [un]lock_page() that already has a page can do the NID thing.

OK?

     Linus

--001a113f8e6644b85605440afc18
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Dec 19, 2016 2:58 PM, &quot;Dave Hansen&quot; &lt;<a href=3D"m=
ailto:dave.hansen@linux.intel.com">dave.hansen@linux.intel.com</a>&gt; wrot=
e:<blockquote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex">
<br>
This boots in a small VM and on a multi-node NUMA system, but has not<br>
been tested widely. =C2=A0<br></blockquote></div></div></div><div dir=3D"au=
to"><br></div><div dir=3D"auto">No, this is wrong.=C2=A0</div><div dir=3D"a=
uto"><br></div><div dir=3D"auto"><div class=3D"gmail_extra"><div class=3D"g=
mail_quote"><blockquote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">
+wait_queue_head_t *bit_waitqueue(void *word, int bit)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0const int __maybe_unused nid =3D page_to_nid(vi=
rt_to_page(word)<wbr>);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __bit_waitqueue(word, bit, nid);<br></bl=
ockquote></div></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">No=
 can do. Part of the problem with the old coffee was that it did that virt_=
to_page() crud. That doesn&#39;t work with the virtually mapped stack.=C2=
=A0</div><div dir=3D"auto"><br></div><div dir=3D"auto">So bit_waitqueue() m=
ust not do the page lookup.=C2=A0</div><div dir=3D"auto"><br></div><div dir=
=3D"auto">Only [un]lock_page() that already has a page can do the NID thing=
.</div><div dir=3D"auto"><br></div><div dir=3D"auto">OK?=C2=A0</div><div di=
r=3D"auto"><br></div><div dir=3D"auto">=C2=A0 =C2=A0 =C2=A0Linus</div></div=
>

--001a113f8e6644b85605440afc18--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
