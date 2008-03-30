Date: Sun, 30 Mar 2008 16:08:43 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080330210843.GB13383@sgi.com>
References: <20080324182122.GA28327@sgi.com> <86802c440803301341i5d116b0en362a51f6d8550482@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803301341i5d116b0en362a51f6d8550482@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> >   unsigned int get_apic_id(void)
> >   {
> >  -       return (apic_read(APIC_ID) >> 24) & 0xFFu;
> >  +       unsigned int id;
> >  +
> >  +       preempt_disable();
> >  +       id = apic_read(APIC_ID);
> >  +       if (uv_system_type >= UV_X2APIC)
> >  +               id  |= __get_cpu_var(x2apic_extra_bits);
> >  +       else
> >  +               id = (id >> 24) & 0xFFu;;
> >  +       preempt_enable();
> >  +       return id;
> >
> 
> you can not shift id here.
> 
> GET_APIC_ID will shift that again.
> 
> you apic id will be 0 for all cpu
> 

I think this is fixed in the patch that I submitted on Friday. I
had to rework the GET_APIC_ID() changes because of the unification
of -32 & -64 apic code. I think the new code is much cleaner...


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
