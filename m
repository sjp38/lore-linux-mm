Received: by py-out-1112.google.com with SMTP id f47so3504969pye.20
        for <linux-mm@kvack.org>; Tue, 25 Mar 2008 20:24:02 -0700 (PDT)
Message-ID: <5d6222a80803252024u6bb5d4ddk556329ec6ce56@mail.gmail.com>
Date: Wed, 26 Mar 2008 00:24:02 -0300
From: "Glauber Costa" <glommer@gmail.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
In-Reply-To: <20080325163103.GA2651@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182122.GA28327@sgi.com> <20080325143059.GB11323@elte.hu>
	 <20080325163103.GA2651@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 1:31 PM, Jack Steiner <steiner@sgi.com> wrote:
> On Tue, Mar 25, 2008 at 03:30:59PM +0100, Ingo Molnar wrote:
>  >
>  > * Jack Steiner <steiner@sgi.com> wrote:
>  >
>  > > Index: linux/arch/x86/kernel/genapic_64.c
>  >
>  > > @@ -69,7 +73,16 @@ void send_IPI_self(int vector)
>  > >
>  > >  unsigned int get_apic_id(void)
>  > >  {
>  > > -   return (apic_read(APIC_ID) >> 24) & 0xFFu;
>  > > +   unsigned int id;
>  > > +
>  > > +   preempt_disable();
>  > > +   id = apic_read(APIC_ID);
>  > > +   if (uv_system_type >= UV_X2APIC)
>  > > +           id  |= __get_cpu_var(x2apic_extra_bits);
>  > > +   else
>  > > +           id = (id >> 24) & 0xFFu;;
>  > > +   preempt_enable();
>  > > +   return id;
>  >
>  > dont we want to put get_apic_id() into struct genapic instead? We
>  > already have ID management there.
>  >
>  > also, we want to unify 32-bit and 64-bit genapic code and just have
>  > genapic all across x86.
>
>  Long term, I think that makes sense. However, I think that should be a
>  separate series of patches since there are significant differences between
>  the 32-bit and 64-bit genapic structs.
>
However, if you add more code, they'll keep diverging. The moment you
touch them, and get your
hands warmed up, is the perfect moment for an integration series.

-- 
Glauber Costa.
"Free as in Freedom"
http://glommer.net

"The less confident you are, the more serious you have to act."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
