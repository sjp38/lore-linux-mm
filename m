Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA626B025E
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 14:19:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so412844820pfg.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 11:19:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id y130si9927775pfg.217.2016.08.03.11.19.31
        for <linux-mm@kvack.org>;
        Wed, 03 Aug 2016 11:19:31 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [PATCH] [RFC] Introduce mmap randomization
Date: Wed, 3 Aug 2016 18:19:19 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC560127C34B@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC5601260068@ORSMSX103.amr.corp.intel.com>
 <20160726214453.GN4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560127815C@ORSMSX103.amr.corp.intel.com>
In-Reply-To: <476DC76E7D1DF2438D32BFADF679FC560127815C@ORSMSX103.amr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jason Cooper' <jason@lakedaemon.net>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'kernel-hardening@lists.openwall.com'" <kernel-hardening@lists.openwall.com>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'keescook@chromium.org'" <keescook@chromium.org>, "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>, "'nnk@google.com'" <nnk@google.com>, "'jeffv@google.com'" <jeffv@google.com>, "'salyzyn@android.com'" <salyzyn@android.com>, "'dcashman@android.com'" <dcashman@android.com>

<snip>
>=20
> >
> > I would highly recommend studying those prior use cases and answering
> > those concerns before progressing too much further.  As I've mentioned
> > elsewhere, you'll need to quantify the increased difficulty to the
> > attacker that your patch imposes.  Personally, I would assess that firs=
t to see if
> it's worth the effort at all.
>=20
> Yes agreed.
>=20

For those following or those who care I have some preliminary results from =
a UML test bench. I need to set up better
testing, this I know :-P and test under constrained environments etc.

I ran 100,000 execs of bash and checked pmap for the location of libc's sta=
rt address. I recorded this and kept track of the lowest
address it was loaded at as well as the highest, the range is aprox 37 bits=
 of entropy. I calculated the Shannon entropy by calculating the frequency
of each address that libc was loaded at per 100,000 invocations, I am not s=
ure if this is an abuse of that, considering Shannon's entropy is usually u=
sed
to calculate the entropy of byte sized units in a file (below you will find=
 my city script). Plotting the data, it looked fairly random. Number theory=
 is
not my strong suit, so if anyone has better ways of measuring entropy, I'm =
all ears, links appreciated.

I'm going to fire up some VMs in the coming weeks and test this more, ill p=
ost back with results if they differ from UML. Including ARM tablets runnin=
g
Android.

low: 0x40000000
high: 0x401cb15000
range: 0x3fdcb15000
Shannon entropy: 10.514440

#!/usr/bin/env python

# modified from: http://www.kennethghartman.com/calculate-file-entropy/

import math
import sys

low=3DNone
high=3DNone

if len(sys.argv) !=3D 2:=20
    print "Usage: file_entropy.py [path]filename"=20
    sys.exit()
=20
d =3D {}
items=3D0
with open(sys.argv[1]) as f:
    for line in f:
	line =3D line.strip()
	line =3D line.lstrip("0")
	#print line
	items =3D items + 1
        if line not in d:
            d[line] =3D 1
        else:
            d[line] =3D d[line] + 1

	x =3D int("0x" + line, 16)
	if low =3D=3D None:
		low =3D x
	if high =3D=3D None:
		high =3D x

	if x < low:
		low =3D x

	if x > high:
		high =3D x


#print str(items)

#print d

print ("low: 0x%x" % low)
print ("high: 0x%x" % high)
print ("range: 0x%x" % (high - low))

# calculate the frequency of each address in the file
# XXX Should this really be in the 64 bit address space?
freqList =3D []=20
for k,v in d.iteritems():=20
    freqList.append(float(v) / items)=20
=20
#print freqList

# Shannon entropy=20
ent =3D 0.0=20
for freq in freqList:=20
    if freq > 0:=20
        ent =3D ent + freq * math.log(freq, 2)=20
ent =3D -ent=20
print ('Shannon entropy: %f' % ent  )

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
