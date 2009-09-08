Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 06A5B6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 12:24:25 -0400 (EDT)
Received: by iwn33 with SMTP id 33so1358481iwn.24
        for <linux-mm@kvack.org>; Tue, 08 Sep 2009 09:24:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1252426288.12145.112.camel@pc1117.cambridge.arm.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
	<1252111494-7593-3-git-send-email-lrodriguez@atheros.com>
	<1252426288.12145.112.camel@pc1117.cambridge.arm.com>
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Date: Tue, 8 Sep 2009 09:16:56 -0700
Message-ID: <43e72e890909080916j159c5fadgda3f2c87aa3b965@mail.gmail.com>
Subject: Re: [PATCH v3 2/5] kmemleak: add clear command support
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Tue, Sep 8, 2009 at 9:11 AM, Catalin Marinas<catalin.marinas@arm.com> wr=
ote:
> On Fri, 2009-09-04 at 17:44 -0700, Luis R. Rodriguez wrote:
>> =C2=A0/*
>> + * We use grey instead of black to ensure we can do future
>> + * scans on the same objects. If we did not do future scans
>> + * these black objects could potentially contain references to
>> + * newly allocated objects in the future and we'd end up with
>> + * false positives.
>> + */
>> +static void kmemleak_clear(void)
>> +{
>> + =C2=A0 =C2=A0 struct kmemleak_object *object;
>> + =C2=A0 =C2=A0 unsigned long flags;
>> +
>> + =C2=A0 =C2=A0 stop_scan_thread();
>> +
>> + =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 list_for_each_entry_rcu(object, &object_list, object_lis=
t) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&object->l=
ock, flags);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((object->flags & OBJECT_=
REPORTED) &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unreferenced_o=
bject(object))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
object->min_count =3D -1;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&obje=
ct->lock, flags);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 rcu_read_unlock();
>> +
>> + =C2=A0 =C2=A0 start_scan_thread();
>> +}
>
> Do we need to stop and start the scanning thread here? When starting it,
> it will trigger a memory scan automatically. I don't think we want this
> as a side-effect, so I dropped these lines from your patch.

OK thanks.

> Also you set min_count to -1 here which means black object, so a
> subsequent patch corrects it. I'll set min_count to 0 here in case
> anyone bisects over it.

Dah, thanks for catching that, seems I only fixed the named set.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
