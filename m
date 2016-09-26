Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09D66280279
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:48:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id cg13so374059625pac.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:48:45 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id tj3si26960051pab.171.2016.09.26.14.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 14:48:45 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id oz2so9272021pac.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:48:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DM2PR21MB00897967DF6E1C0D57DFA9F4CBCD0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
 <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
 <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
 <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com>
 <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
 <CA+55aFw9=wqyA4xO1KKJoH7xsj6poWFrWTddcNBR5tkDOn8SYg@mail.gmail.com> <DM2PR21MB00897967DF6E1C0D57DFA9F4CBCD0@DM2PR21MB0089.namprd21.prod.outlook.com>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Mon, 26 Sep 2016 23:48:44 +0200
Message-ID: <CALXu0Udkqfhgvt-CKzYs4-rTo8fUZnsNV1xq53gMVFFgzMjgww@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

You might also try to use valid, plain ISO C99 instead of perverted
gcc extensions which only cause a lot of trouble in the long run.

Ced

On 26 September 2016 at 23:28, Matthew Wilcox <mawilcox@microsoft.com> wrot=
e:
> From: linus971@gmail.com [mailto:linus971@gmail.com] On Behalf Of Linus T=
orvalds
>> On Sun, Sep 25, 2016 at 12:04 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>> >        It gets rid of
>> > the ad-hoc arithmetic in radix_tree_descend(), and just makes all that
>> > be inside the is_sibling_entry() logic instead. Which got renamed and
>> > made to actually return the main sibling.
>>
>> Sadly, it looks like gcc generates bad code for this approach. Looks
>> like it ends up testing the resulting sibling pointer twice (because
>> we explicitly disable -fno-delete-null-pointer-checks in the kernel,
>> and we have no way to say "look, I know this pointer I'm returning is
>> non-null").
>>
>> So a smaller patch that keeps the old boolean "is_sibling_entry()" but
>> then actually *uses* that inside radix_tree_descend() and then tries
>> to make the nasty cast to "void **" more legible by making it use a
>> temporary variable seems to be a reasonable balance.
>>
>> At least I feel like I can still read the code, but admittedly by now
>> that may be because I've stared at those few lines so much that I feel
>> like I know what's going on. So maybe the code isn't actually any more
>> legible after all.
>>
>> .. and unlike my previous patch, it actually generates better code
>> than the original (while still passing the fixed test-suite, of
>> course). The reason seems to be exactly that temporary variable,
>> allowing us to just do
>>
>>         entry =3D rcu_dereference_raw(*sibentry);
>>
>> rather than doing
>>
>>         entry =3D rcu_dereference_raw(parent->slots[offset]);
>>
>> with the re-computed offset.
>>
>> So I think I'll commit this unless somebody screams.
>
> Acked-by: Matthew Wilcox <mawilcox@microsoft.com>
>
> I don't love it.  But I think it's a reasonable fix for this point in the=
 release cycle, and I have an idea for changing the representation of sibli=
ng slots that will make this moot.
>
> (Basically adopting Konstantin's idea for using the *last* entry instead =
of the *first*, and then using entries of the form (offset << 2 | RADIX_TRE=
E_INTERNAL_NODE), so we can identify sibling entries without knowing the pa=
rent pointer, and we can go straight from sibling entry to slot offset as a=
 shift rather than as a pointer subtraction).



--=20
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
