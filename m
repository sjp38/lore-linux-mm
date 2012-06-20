Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6AC306B005D
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 20:29:29 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
Date: Tue, 19 Jun 2012 17:29:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: help converting zcache from sysfs to debugfs?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Sasha Levin <levinsasha928@gmail.com>

Zcache (in staging) has a large number of read-only counters that
are primarily of interest to developers.  These counters are currently
visible from sysfs.  However sysfs is not really appropriate and
zcache will need to switch to debugfs before it can be promoted
out of staging.

For some of the counters, it is critical that they remain accurate so
an atomic_t must be used.  But AFAICT there is no way for debugfs
to work with atomic_t.

Is that correct?  Or am I missing something?

Assuming it is correct, I have a workaround but it is ugly:

static unsigned long counterX;
static atomic_t atomic_counterX;

=09counterX =3D atomic_*_return(atomic_counterX)

and use atomic_counter in normal code and counter for debugfs.

This works but requires each counter to be stored twice AND
makes the code look ugly.

Is there a better way?  I can probably bury the ugliness in
macros but that doesn't solve the duplicate storage.  (Though
since there are only about a dozen, maybe it doesn't matter?)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
