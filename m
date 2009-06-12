Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8A1016B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:47:49 -0400 (EDT)
Received: by fxm12 with SMTP id 12so94446fxm.38
        for <linux-mm@kvack.org>; Fri, 12 Jun 2009 02:49:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090612091002.GA32052@elte.hu>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
Date: Fri, 12 Jun 2009 12:49:17 +0300
Message-ID: <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 12:10 PM, Ingo Molnar<mingo@elte.hu> wrote:
>> @@ -1548,6 +1548,20 @@ new_slab:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_freelist;
>> =A0 =A0 =A0 }
>>
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Lets not wait if we're booting up or suspending even if t=
he user
>> + =A0 =A0 =A0* asks for it.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (system_state !=3D SYSTEM_RUNNING)
>> + =A0 =A0 =A0 =A0 =A0 =A0 gfpflags &=3D ~__GFP_WAIT;
>
> Hiding that bug like that is not particularly clean IMO. We should
> not let system_state hacks spread like that.
>
> We emit a debug warning but dont crash, so all should be fine and
> the culprits can then be fixed, right?

OK, lets not use system_state then and go with Ben's approach then.
Again, neither of the patches are about "hiding buggy callers" but
changing allocation policy wrt. gfp flags during boot (and later on
during suspend).

                                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
