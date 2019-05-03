Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E275BC004C9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 21:48:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 581E6206C1
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 21:48:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 581E6206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A02876B0005; Fri,  3 May 2019 17:48:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98DDC6B0006; Fri,  3 May 2019 17:48:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8060D6B0007; Fri,  3 May 2019 17:48:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCC56B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 17:48:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m35so3782688pgl.6
        for <linux-mm@kvack.org>; Fri, 03 May 2019 14:48:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent
         :mime-version;
        bh=c9v6yIHa2aYDAQnqqql4RhVIhVYaI5WGP3KIe0JWqJM=;
        b=t7o4OTXveh6QQ6cBT8hTopWW30HDNf9aLMoMmXceKz1TRZH0DPkw1wgjERfKCX2b0I
         QZqcSHfF3cDKKzNLLsaXFqzFbqNkZywqz09qjw5kI+EHL0pVsbA7hltlExZAuRiBKFo8
         1KEdrNcs+DDpytPM27hIxnazpFD4rKIJmE9LLeBgn8W81Puby5cEh0jFIdKxAknTde5b
         fHmZHz8eGL1fo+BZqSA/NcSQ67WAeVVrAVDK6br4Bfp3tv5rr1L04LWi9/9zXaRZ/DZ2
         pFFgAYDswnF4v5bS8zp6WR2t7Hp+SbU4AYQ718xcJ2oNgJxeDd8eggtVN3coAiuLPprA
         SDYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWcn2t2fcYxNSPbRRlm8KhWXpIASzorrjetu98wsK/R9f14680A
	blv/I5Cqzo5FhnJVmv6+O2l4QYXk5cgicVhkDl9UpZPrP82KhB9RZeDFNOVLtdarch5SnqsiiO9
	IT7h2gt1+XdF3ZgT1iK8pi2UrfLp9kPLXPm19HEI8wiB5nAztXDY2cFkUbEPiBC+Enw==
X-Received: by 2002:a62:4115:: with SMTP id o21mr14275589pfa.153.1556920133954;
        Fri, 03 May 2019 14:48:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZO2nPxmGish9Dxvo+BefbhLh2qUjTm/p/HcTTfwe55sJL5asx+7BvG5kXTt3GE6QnxhrR
X-Received: by 2002:a62:4115:: with SMTP id o21mr14275442pfa.153.1556920132432;
        Fri, 03 May 2019 14:48:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556920132; cv=none;
        d=google.com; s=arc-20160816;
        b=nKSAeLfxLhc7VpvjZNHTtC6xnyHrHmqBPGksOqhZgt2YfN7LjKBGszrxfKNX4BKLWJ
         0/wcupvnfMlbbMOl2S1q0BodkTPqAub0OERxOoMjSyM+5BV8Ls05l+mFwb/r6kx7CmDt
         tFLSgU+rBwW7jHhkA6nJLkIGkZz+ECb7EtsZtKr7G4JPcVbe45PYIsWLPrBz9NtAtcUb
         oebasBo2+MIcthdGdiJeY3USGvKPlT3FtClQWy4nujxdk9sbgD5wV+ho4sFAVqdEOTF6
         4xKv/7D01USKlHSawhoH90h0hhQeUSJGWRincZ5zfi9Yz9uImqyPZEZqEBtyGv7eoBKY
         Rb3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:content-language:accept-language
         :in-reply-to:references:message-id:date:thread-index:thread-topic
         :subject:cc:to:from;
        bh=c9v6yIHa2aYDAQnqqql4RhVIhVYaI5WGP3KIe0JWqJM=;
        b=WPgnU5yoNJh7fhqt25Bf+DcDWnhn8NJ7XbpNi9xPek5FUtK4OsLjiFVUAeEvrv7O8J
         GIwF957puRef423tEGvWp53bQOSic2Dq65Vp2Mtpvdv9rnsf92RJ+zY18vOCB/JDyZq6
         lpKMkzWvb7tD6DJoROGKSrRMICbCJOcrEMbFd/u765BMXoFmiWJp/xfv6cDlGs29HVZV
         6a26YDTZAgwlNDOrqd6JtuS4xTHA7vsSq8seg1Pk4+a0DvwW9YhnDqNVROmGoVMMVDJZ
         hAd1O4OQ3CZmks4gZxA6pMbbxolyQuvhOeNApsWW8BunEtvO0GZJ9LDO64jaPctXwrmq
         JHlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t75si3231102pgc.23.2019.05.03.14.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 14:48:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 May 2019 14:48:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,427,1549958400"; 
   d="scan'208,50?p7s'208,50?gz'208,50,50";a="296819205"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by orsmga004.jf.intel.com with ESMTP; 03 May 2019 14:48:50 -0700
Received: from fmsmsx111.amr.corp.intel.com (10.18.116.5) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 3 May 2019 14:48:50 -0700
Received: from fmsmsx113.amr.corp.intel.com ([169.254.13.30]) by
 fmsmsx111.amr.corp.intel.com ([169.254.12.101]) with mapi id 14.03.0415.000;
 Fri, 3 May 2019 14:48:49 -0700
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
To: "pasha.tatashin@soleen.com" <pasha.tatashin@soleen.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>, "sashal@kernel.org"
	<sashal@kernel.org>, "bp@suse.de" <bp@suse.de>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "tiwai@suse.de"
	<tiwai@suse.de>, "Williams, Dan J" <dan.j.williams@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com"
	<jglisse@redhat.com>, "zwisler@kernel.org" <zwisler@kernel.org>,
	"mhocko@suse.com" <mhocko@suse.com>, "Jiang, Dave" <dave.jiang@intel.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>, "Busch, Keith"
	<keith.busch@intel.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"Huang, Ying" <ying.huang@intel.com>, "Wu, Fengguang"
	<fengguang.wu@intel.com>, "baiyaowei@cmss.chinamobile.com"
	<baiyaowei@cmss.chinamobile.com>
Subject: Re: [v5 0/3] "Hotremove" persistent memory
Thread-Topic: [v5 0/3] "Hotremove" persistent memory
Thread-Index: AQHVARb3UO0Lxl+oRESN1JIk0+ExN6ZYxIMAgAAO+YCAAAy2gIAAAc0AgAGFJIA=
Date: Fri, 3 May 2019 21:48:48 +0000
Message-ID: <e690b3956c16045270b990e50bbf7e9d5352fd4b.camel@intel.com>
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
	 <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com>
	 <CA+CK2bA=E4zRFb0Qky=baOQi_LF4x4eu8KVdEkhPJo3wWr8dYQ@mail.gmail.com>
	 <9bf70d80718d014601361f07813b68e20b089201.camel@intel.com>
	 <CA+CK2bBRwFN342x3t77CBrFTrXUn3VMn6a-cf-y0fF+2DBYpbA@mail.gmail.com>
In-Reply-To: <CA+CK2bBRwFN342x3t77CBrFTrXUn3VMn6a-cf-y0fF+2DBYpbA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.5 (3.30.5-1.fc29) 
x-originating-ip: [10.254.186.240]
Content-Type: multipart/signed; micalg=sha-1;
	protocol="application/x-pkcs7-signature"; boundary="=-xVRS+3lY8G+YCqvW3zMs"
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=-xVRS+3lY8G+YCqvW3zMs
Content-Type: multipart/mixed; boundary="=-d2rCgOeCw/hJEv9F+FGR"


--=-d2rCgOeCw/hJEv9F+FGR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-05-02 at 18:36 -0400, Pavel Tatashin wrote:
> > Yes, here is the qemu config:
> >=20
> > qemu-system-x86_64
> >         -machine accel=3Dkvm
> >         -machine pc-i440fx-2.6,accel=3Dkvm,usb=3Doff,vmport=3Doff,dump-=
guest-core=3Doff,nvdimm
> >         -cpu Haswell-noTSX
> >         -m 12G,slots=3D3,maxmem=3D44G
> >         -realtime mlock=3Doff
> >         -smp 8,sockets=3D2,cores=3D4,threads=3D1
> >         -numa node,nodeid=3D0,cpus=3D0-3,mem=3D6G
> >         -numa node,nodeid=3D1,cpus=3D4-7,mem=3D6G
> >         -numa node,nodeid=3D2
> >         -numa node,nodeid=3D3
> >         -drive file=3D/virt/fedora-test.qcow2,format=3Dqcow2,if=3Dnone,=
id=3Ddrive-virtio-disk1
> >         -device virtio-blk-pci,scsi=3Doff,bus=3Dpci.0,addr=3D0x9,drive=
=3Ddrive-virtio-disk1,id=3Dvirtio-disk1,bootindex=3D1
> >         -object memory-backend-file,id=3Dmem1,share,mem-path=3D/virt/nv=
dimm1,size=3D16G,align=3D128M
> >         -device nvdimm,memdev=3Dmem1,id=3Dnv1,label-size=3D2M,node=3D2
> >         -object memory-backend-file,id=3Dmem2,share,mem-path=3D/virt/nv=
dimm2,size=3D16G,align=3D128M
> >         -device nvdimm,memdev=3Dmem2,id=3Dnv2,label-size=3D2M,node=3D3
> >         -serial stdio
> >         -display none
> >=20
> > For the command list - I'm using WIP patches to ndctl/daxctl to add the
> > command I mentioned earlier. Using this command, I can reproduce the
> > lockdep issue. I thought I should be able to reproduce the issue by
> > onlining/offlining through sysfs directly too - something like:
> >=20
> >    node=3D"$(cat /sys/bus/dax/devices/dax0.0/target_node)"
> >    for mem in /sys/devices/system/node/node"$node"/memory*; do
> >      echo "offline" > $mem/state
> >    done
> >=20
> > But with that I can't reproduce the problem.
> >=20
> > I'll try to dig a bit deeper into what might be happening, the daxctl
> > modifications simply amount to doing the same thing as above in C, so
> > I'm not immediately sure what might be happening.
> >=20
> > If you're interested, I can post the ndctl patches - maybe as an RFC -
> > to test with.
>=20
> I could apply the patches and test with them. Also, could you please
> send your kernel config.
>=20
Hi Pavel,

I've CC'd you on the patches mentioned above, and also pushed them to a
'kmem-pending' branch on github:

https://github.com/pmem/ndctl/tree/kmem-pending

After building ndctl from the above, you will want to run:

# daxctl reconfigure-device --mode=3Dsystem-ram dax0.0
(this will also have onlined the memory sections)

# daxctl reconfigure-device --mode=3Ddevdax --attempt-offline dax0.0
(this triggers the lockdep warnings)

I've attached the kernel config here too (gzipped).

Thanks,
	-Vishal

--=-d2rCgOeCw/hJEv9F+FGR
Content-Type: application/gzip; name="config.gz"
Content-Disposition: attachment; filename="config.gz"
Content-Transfer-Encoding: base64

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


--=-d2rCgOeCw/hJEv9F+FGR--

--=-xVRS+3lY8G+YCqvW3zMs
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
jHDdOlVoeO8s75q7ae/9zxbc1Jab2SkZ9M3ZyOVBmG9d/KAzgdCDdj24RMHSjCHkXrzJXSkCAwEA
AaOCAjMwggIvMB0GA1UdDgQWBBRTGAAOjKJMIsSTidbEIUJHct/yNjAfBgNVHSMEGDAWgBQeaSq0
3Cj+RxhOIQs/vKwRL/CY9TBlBgNVHR8EXjBcMFqgWKBWhlRodHRwOi8vd3d3LmludGVsLmNvbS9y
ZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjA0
QS5jcmwwgZ8GCCsGAQUFBwEBBIGSMIGPMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1
aW5nJTIwQ0ElMjA0QS5jcnQwIgYIKwYBBQUHMAGGFmh0dHA6Ly9vY3NwLmludGVsLmNvbS8wCwYD
VR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWOn1OCkcAJ
Z4HevTmV8EMCAWQCAQkwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQBgjcKAwwwKQYJKwYBBAGC
NxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMME0GA1UdEQRGMESgKAYKKwYBBAGCNxQC
A6AaDBh2aXNoYWwubC52ZXJtYUBpbnRlbC5jb22BGHZpc2hhbC5sLnZlcm1hQGludGVsLmNvbTAN
BgkqhkiG9w0BAQUFAAOCAQEAqgg2JZi+YMm+J+kkQMceW7b/tIMXVSO6UbUSixwzwS6GXl0a9sat
jUED06fKUHYFNOm9xDM5KKWQVugD+r5ZbySfkGj3OGmJGoBX2t61PqKveEPb9IoJF8n67p3LW8i4
btwLIBrDXxdXTiPi2ktulKcP6mKZtSrXjaksbuqWzALdXXtMTiiycSzSqJA/oK5ii4j83XCl2l8u
7NsfgI3cXwzDul4/gumRaQs6Axs7dlPQvTIttBl2zEa3zZ8o9kq6qJcPH+7IJEg2+4XiGdla+r4j
AX/uuDvM0Clnm2wvDlniw3E+fo5te1Cb39VcEsRbktawbqWnZZ+vza8x/igFAzGCAhcwggITAgEB
MIGQMHkxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEUMBIGA1UEBxMLU2FudGEgQ2xhcmExGjAY
BgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJ
c3N1aW5nIENBIDRBAhMzAADEX95Li1xSDli/AAAAAMRfMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xOTA1MDMyMTQ4NDdaMCMGCSqGSIb3DQEJ
BDEWBBRJz7oWD+jPzMzlvEFhLK/azFrfSDANBgkqhkiG9w0BAQEFAASCAQBnvuy5hdlshc5wEMB0
/MV7Yhud6vEJJnCn6ReOldt0gG0hqzTa2w5QF5MuEavU2rNj7NCr70600dq1V80lRmhi0YUqfFJR
wz/ejT2S6AXDSg/hRFR+MSi6wc0RtIGz6htjYjgorjSbMaqTgiMMcd+gKKvh6kpouRsabY4QNtYk
zcxOpbUrzIk71OFKdbmsS80S8AAHMJvmz5OAMuOLkxZ33K2Mk/yVY330ZQ7mYYUpCf8/bprm5xZs
LgL73XLrrgI1fQNHloi3/RQMqBoYUcB8184FjzQdf2ORxtY4FPlvyH6mHLVCu73lhjlHS/RHmuAy
zotDw6TE3IRqAG23GVx9AAAAAAAA


--=-xVRS+3lY8G+YCqvW3zMs--

