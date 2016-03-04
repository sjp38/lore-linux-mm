Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 460166B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 05:14:34 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so13683195wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 02:14:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r123si3237103wmb.8.2016.03.04.02.14.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 02:14:33 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Fri, 04 Mar 2016 21:14:24 +1100
Subject: Re: [PATCH 3/3] radix-tree: support locking of individual exception entries.
In-Reply-To: <87a8mfm86l.fsf@notabene.neil.brown.name>
References: <145663588892.3865.9987439671424028216.stgit@notabene> <145663616983.3865.11911049648442320016.stgit@notabene> <20160303131033.GC12118@quack.suse.cz> <87a8mfm86l.fsf@notabene.neil.brown.name>
Message-ID: <87si06lfcv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain

On Fri, Mar 04 2016, NeilBrown wrote:

>
> By not layering on top of wait_bit_key, you've precluded the use of the
> current page wait_queues for these locks - you need to allocate new wait
> queue heads.
>
> If in
>
>> +struct wait_exceptional_entry_queue {
>> +	wait_queue_t wait;
>> +	struct exceptional_entry_key key;
>> +};
>
> you had the exceptional_entry_key first (like wait_bit_queue does) you
> would be closer to being able to re-use the queues.

Scratch that bit, I was confusing myself again.  Sorry.
Each wait_queue_t has it's own function so one function will never be
called on other items in the queue - of course.

>
> Also I don't think it is safe to use an exclusive wait.  When a slot is
> deleted, you need to wake up *all* the waiters.

I think this issue is still valid.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW2WAAAAoJEDnsnt1WYoG5zJQQAIkLrfsjhY9GJHl/sRuTTS5b
IkmZbUQMApM3V2TMxgX07XZ9csVzGUhZpt7NmI5wRF0bYzBk4SJSn3KoawZnz9IG
IPWOfOnPgewzqLs3a9WVADts1fmCYh86nx7zbOL+sQtH+acBOlsz6LzdxtQrE1iv
lu6BrPwQQSnXKAXN7WhjZAm1i0lyJTndQ0x9CdAATcS4E4QyWgnWqLbaPoJK9V/z
xguLQ+tkNUu7MjfLh6ujkf0og14e1YD0a00+3mksXRuWpY0bdC6DHkMUtL9yxlY8
PUtHmAM/ZHE90FIj8qic45jbjkyg2ICNkp6WqBYoNArZIZMu0Rki2TI0bmdduhEp
QPILR7GsjnaMZIV284oiDSUTvyO6GkYPeZ1tVHroShM/V9tP6NUdp8+rMKa+XRPI
SG/FNaVCOeojDZDA+wkuR/vloxge23YaF0uq9Bz+LU7qgurB3oA4xX2jz+8AL+Kt
5WloNpzDQD6JZV/lZYKPoXwXzhiouFBIv06FBqn4X3kKXQ8JxGvHF3NPbtrtvW9T
cyXNmwiP40FOl7HMzePAACMLiaYn+Qg5+S3ADFmN+spR94A+ZzTP1JqVanxbRVx8
ZmLzWKuC5ukdgLD0/CQHZ2m7hoSj39Wy36wI+DglFYq+0nxZHjQrH0709eAUOzd+
8Vd5BsyydcxLw7GPV6m/
=ORUo
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
