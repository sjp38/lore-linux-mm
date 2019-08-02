Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8131C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 393D520880
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=apple.com header.i=@apple.com header.b="RiyM/RDh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 393D520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=apple.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF1186B0003; Fri,  2 Aug 2019 19:28:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC6646B0005; Fri,  2 Aug 2019 19:28:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98DF76B0006; Fri,  2 Aug 2019 19:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72E826B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:28:43 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so84336404iom.18
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:message-id
         :mime-version:subject:date:in-reply-to:cc:to:references;
        bh=3uvcOFokwa+A/bu0YLUjnh+aDDxXmM5FLTBmsaHJCJg=;
        b=nKlKWOjquVmMD+lpgd4T0jg0KsdST/tl2ThNpkc0stYSfQ9hfvGE0T+TKfkcdRTPJr
         msQ5qKubMKdb1BxuBDpNRtJZPLsC+DlNE4QbvTMg0LGY2RzfSlej8TEeY+5q9JxTz+ac
         SAhjxUIBmM0dZXSjlOBiV3tE2kxeOAQhONibK/t8JgPkZGmKYWinGJYlCbtRW69Uwukq
         ybm5Q8IGCyR0shs2eAKlJBnCyIz94RwY8s29EK0ZK/JDNYqmxM/El5EB1jRW552pu4S4
         Jqvd04HlxyMJvm8R8AGmNi6GAfAX4m6WY4sfZWZ0aXfrzWfYvOogWHNTDtz4vo02LUpk
         zEeA==
X-Gm-Message-State: APjAAAXFT/vc4BRgwUBBaIrrEi8hz+bsqhI/puAjYHL8aZlfjsJqTLFd
	ma7O285RDIK8fXUeJBn2hOARkxQ4BT6+0whU2wyI4wiPwunfLOPkG/J3GzIqCt2MRapDeWZozkF
	LHHmgkN/5eiRkMneknvMnue9gusLZhVLkSZt/AA1Uob718qcWPcYkqebn58XBCIBc6Q==
X-Received: by 2002:a6b:e608:: with SMTP id g8mr4852091ioh.88.1564788523177;
        Fri, 02 Aug 2019 16:28:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4wzgaylQ/idtdpcFyxrdIrgR57w9YblqT1fxDUP7VtYjBAFcWPJ/iwuTbgHd1ha1TuwLH
X-Received: by 2002:a6b:e608:: with SMTP id g8mr4852024ioh.88.1564788522074;
        Fri, 02 Aug 2019 16:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564788522; cv=none;
        d=google.com; s=arc-20160816;
        b=mxqxq6SWn8JwVvcIKlbCHZlIu1PYkzaGlHebxhJePMySk7Qi1FbnAPj5dHEWHUOqZZ
         r32H/Q/TmvTPHPOBTeEDorQeGO5zg6t2yy7E44qoKMNVU9dR6oUWnCzOnlKrTJiquTs5
         ln0LjKJC5b4P5WCLqrbgwJ6BWo4CMBoKA2BaneCmaxudvhGd/mPt8VBITq3Ws97bAPl8
         od9FSs4e76oqYcAzUxqEbAA7wgAhUs3eFWCprJ+Lg9IZt5ZD+ks9jhdnhj2qS7Z2o/dp
         dFCQRv736FWjsj6xtUiYMNMD22vOSwyAF+KUOpAdtXkURN+ArfTziJnTXECMS79NQplJ
         NWag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
         :from:sender:dkim-signature;
        bh=3uvcOFokwa+A/bu0YLUjnh+aDDxXmM5FLTBmsaHJCJg=;
        b=w1dpwK8sa2zRvJnDF8jqRmPTzAnPgF0EYXOQs/sYJYYpMB+tR39e0mfERTL7w5v/k+
         5+/xP9V7qRnJjSwrLN0/qyT4U8kdCDsk0ndJkRdPBajJ2i92l1BCbh8wgQRe0OG77qS2
         MEK3TieKlbu0TPM34r2Uv3sDWr93t1ZP3tVEjulurBxasHFL1LJeDNh0sijW0PzKOtzZ
         voJ5Axlk80nX1FRCfOCFp5xitJBxmnLm+HrYZ7fRivJvz9B+2WboWH2AN7IB5Xf70rlv
         GmptxGHZwHFRF01VAFxR00cW2v0CWfJs1WB+ENrv0DKollPcAFFROm9m2rQVRwDZOfDy
         6B1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b="RiyM/RDh";
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.151.62.66 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from nwk-aaemail-lapp01.apple.com (nwk-aaemail-lapp01.apple.com. [17.151.62.66])
        by mx.google.com with ESMTPS id a16si80503578iol.140.2019.08.02.16.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 16:28:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of msharbiani@apple.com designates 17.151.62.66 as permitted sender) client-ip=17.151.62.66;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b="RiyM/RDh";
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.151.62.66 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from pps.filterd (nwk-aaemail-lapp01.apple.com [127.0.0.1])
	by nwk-aaemail-lapp01.apple.com (8.16.0.27/8.16.0.27) with SMTP id x72NQZqc054403;
	Fri, 2 Aug 2019 16:28:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=apple.com; h=sender : from :
 message-id : content-type : mime-version : subject : date : in-reply-to :
 cc : to : references; s=20180706;
 bh=3uvcOFokwa+A/bu0YLUjnh+aDDxXmM5FLTBmsaHJCJg=;
 b=RiyM/RDhTLCX3w99LXerZLwVMUSLI8a0pMpXsn2ZFzV9wM9HfraHjuyKPYtJyVQxkbSm
 OEsKxFhCDGznlJafA3W+RHOvtkgwnOrSJ0rEwzq5IM3o/tvoW/K58UvvfrfP7EiOFCsE
 FfoP/uMueQqEwrxBJrciOOiaAQdnoXiMBX/8hb+I8G8j4CYigKMxXeWlqvlivYass9xH
 67VigmnPYN9tG/V2Odv25k7G5jVa5eqesG4FqxnQDAp+aki97OWgdovA9seMMQmap6Mk
 amug30+GU1qLizIClQQl2RQJR26e90nKsh35NvnBat+sW2HmVtFof03fIMPN0LAKKjNz ZQ== 
Received: from mr2-mtap-s03.rno.apple.com (mr2-mtap-s03.rno.apple.com [17.179.226.135])
	by nwk-aaemail-lapp01.apple.com with ESMTP id 2u412druhr-17
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO);
	Fri, 02 Aug 2019 16:28:38 -0700
Received: from nwk-mmpp-sz09.apple.com
 (nwk-mmpp-sz09.apple.com [17.128.115.80]) by mr2-mtap-s03.rno.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPS id <0PVM00J2DUJN7Q30@mr2-mtap-s03.rno.apple.com>; Fri,
 02 Aug 2019 16:28:35 -0700 (PDT)
Received: from process_milters-daemon.nwk-mmpp-sz09.apple.com by
 nwk-mmpp-sz09.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) id <0PVM00500UGMJA00@nwk-mmpp-sz09.apple.com>; Fri,
 02 Aug 2019 16:28:35 -0700 (PDT)
X-Va-A: 
X-Va-T-CD: b41360010a109a57a86dac7242f659de
X-Va-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-Va-R-CD: 1835f3c54d533384876758843bc94ede
X-Va-CD: 0
X-Va-ID: 48d16b0a-e100-479d-8512-23eb08e90964
X-V-A: 
X-V-T-CD: b41360010a109a57a86dac7242f659de
X-V-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-V-R-CD: 1835f3c54d533384876758843bc94ede
X-V-CD: 0
X-V-ID: c0c6b1ab-6226-4e77-8a05-9d0f5d6fc430
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,,
 definitions=2019-08-02_10:,, signatures=0
Received: from iceman.apple.com (iceman.apple.com [17.228.212.91])
 by nwk-mmpp-sz09.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPSA id <0PVM00B8EUJETF20@nwk-mmpp-sz09.apple.com>; Fri,
 02 Aug 2019 16:28:26 -0700 (PDT)
From: Masoud Sharbiani <msharbiani@apple.com>
Message-id: <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
Content-type: multipart/signed;
 boundary="Apple-Mail=_8FA53783-E4EB-4C34-821A-CE60ADDEE4C7";
 protocol="application/pkcs7-signature"; micalg=sha-256
MIME-version: 1.0 (Mac OS X Mail 13.0 \(3570.1\))
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Date: Fri, 02 Aug 2019 16:28:25 -0700
In-reply-to: <20190802191430.GO6461@dhcp22.suse.cz>
Cc: Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
        vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
X-Mailer: Apple Mail (2.3570.1)
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_10:,,
 signatures=0
X-Proofpoint-AD-Result: pass
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail=_8FA53783-E4EB-4C34-821A-CE60ADDEE4C7
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_182468D9-8FE1-460D-9C2F-1524ACE18F0F"


--Apple-Mail=_182468D9-8FE1-460D-9C2F-1524ACE18F0F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On Aug 2, 2019, at 12:14 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Fri 02-08-19 11:00:55, Masoud Sharbiani wrote:
>>=20
>>=20
>>> On Aug 2, 2019, at 7:41 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>>=20
>>> On Fri 02-08-19 07:18:17, Masoud Sharbiani wrote:
>>>>=20
>>>>=20
>>>>> On Aug 2, 2019, at 12:40 AM, Michal Hocko <mhocko@kernel.org> =
wrote:
>>>>>=20
>>>>> On Thu 01-08-19 11:04:14, Masoud Sharbiani wrote:
>>>>>> Hey folks,
>>>>>> I=E2=80=99ve come across an issue that affects most of 4.19, 4.20 =
and 5.2 linux-stable kernels that has only been fixed in 5.3-rc1.
>>>>>> It was introduced by
>>>>>>=20
>>>>>> 29ef680 memcg, oom: move out_of_memory back to the charge path=20
>>>>>=20
>>>>> This commit shouldn't really change the OOM behavior for your =
particular
>>>>> test case. It would have changed MAP_POPULATE behavior but your =
usage is
>>>>> triggering the standard page fault path. The only difference with
>>>>> 29ef680 is that the OOM killer is invoked during the charge path =
rather
>>>>> than on the way out of the page fault.
>>>>>=20
>>>>> Anyway, I tried to run your test case in a loop and leaker always =
ends
>>>>> up being killed as expected with 5.2. See the below oom report. =
There
>>>>> must be something else going on. How much swap do you have on your
>>>>> system?
>>>>=20
>>>> I do not have swap defined.=20
>>>=20
>>> OK, I have retested with swap disabled and again everything seems to =
be
>>> working as expected. The oom happens earlier because I do not have =
to
>>> wait for the swap to get full.
>>>=20
>>=20
>> In my tests (with the script provided), it only loops 11 iterations =
before hanging, and uttering the soft lockup message.
>>=20
>>=20
>>> Which fs do you use to write the file that you mmap?
>>=20
>> /dev/sda3 on / type xfs =
(rw,relatime,seclabel,attr2,inode64,logbufs=3D8,logbsize=3D32k,noquota)
>>=20
>> Part of the soft lockup path actually specifies that it is going =
through __xfs_filemap_fault():
>=20
> Right, I have just missed that.
>=20
> [...]
>=20
>> If I switch the backing file to a ext4 filesystem (separate hard =
drive), it OOMs.
>>=20
>>=20
>> If I switch the file used to /dev/zero, it OOMs:=20
>> =E2=80=A6
>> Todal sum was 0. Loop count is 11
>> Buffer is @ 0x7f2b66c00000
>> ./test-script-devzero.sh: line 16:  3561 Killed                  =
./leaker -p 10240 -c 100000
>>=20
>>=20
>>> Or could you try to
>>> simplify your test even further? E.g. does everything work as =
expected
>>> when doing anonymous mmap rather than file backed one?
>>=20
>> It also OOMs with MAP_ANON.=20
>>=20
>> Hope that helps.
>=20
> It helps to focus more on the xfs reclaim path. Just to be sure, is
> there any difference if you use cgroup v2? I do not expect to be but
> just to be sure there are no v1 artifacts.

I was unable to use cgroups2. I=E2=80=99ve created the new control =
group, but the attempt to move a running process into it fails with =
=E2=80=98Device or resource busy=E2=80=99.

Masoud

> --=20
> Michal Hocko
> SUSE Labs


--Apple-Mail=_182468D9-8FE1-460D-9C2F-1524ACE18F0F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><br =
class=3D""><div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Aug 2, 2019, at 12:14 PM, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@kernel.org" class=3D"">mhocko@kernel.org</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">On Fri 02-08-19 11:00:55, Masoud =
Sharbiani wrote:</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br class=3D""><br =
class=3D""><blockquote type=3D"cite" class=3D"">On Aug 2, 2019, at 7:41 =
AM, Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org" =
class=3D"">mhocko@kernel.org</a>&gt; wrote:<br class=3D""><br =
class=3D"">On Fri 02-08-19 07:18:17, Masoud Sharbiani wrote:<br =
class=3D""><blockquote type=3D"cite" class=3D""><br class=3D""><br =
class=3D""><blockquote type=3D"cite" class=3D"">On Aug 2, 2019, at 12:40 =
AM, Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org" =
class=3D"">mhocko@kernel.org</a>&gt; wrote:<br class=3D""><br =
class=3D"">On Thu 01-08-19 11:04:14, Masoud Sharbiani wrote:<br =
class=3D""><blockquote type=3D"cite" class=3D"">Hey folks,<br =
class=3D"">I=E2=80=99ve come across an issue that affects most of 4.19, =
4.20 and 5.2 linux-stable kernels that has only been fixed in =
5.3-rc1.<br class=3D"">It was introduced by<br class=3D""><br =
class=3D"">29ef680 memcg, oom: move out_of_memory back to the charge =
path<span class=3D"Apple-converted-space">&nbsp;</span><br =
class=3D""></blockquote><br class=3D"">This commit shouldn't really =
change the OOM behavior for your particular<br class=3D"">test case. It =
would have changed MAP_POPULATE behavior but your usage is<br =
class=3D"">triggering the standard page fault path. The only difference =
with<br class=3D"">29ef680 is that the OOM killer is invoked during the =
charge path rather<br class=3D"">than on the way out of the page =
fault.<br class=3D""><br class=3D"">Anyway, I tried to run your test =
case in a loop and leaker always ends<br class=3D"">up being killed as =
expected with 5.2. See the below oom report. There<br class=3D"">must be =
something else going on. How much swap do you have on your<br =
class=3D"">system?<br class=3D""></blockquote><br class=3D"">I do not =
have swap defined.<span class=3D"Apple-converted-space">&nbsp;</span><br =
class=3D""></blockquote><br class=3D"">OK, I have retested with swap =
disabled and again everything seems to be<br class=3D"">working as =
expected. The oom happens earlier because I do not have to<br =
class=3D"">wait for the swap to get full.<br class=3D""><br =
class=3D""></blockquote><br class=3D"">In my tests (with the script =
provided), it only loops 11 iterations before hanging, and uttering the =
soft lockup message.<br class=3D""><br class=3D""><br =
class=3D""><blockquote type=3D"cite" class=3D"">Which fs do you use to =
write the file that you mmap?<br class=3D""></blockquote><br =
class=3D"">/dev/sda3 on / type xfs =
(rw,relatime,seclabel,attr2,inode64,logbufs=3D8,logbsize=3D32k,noquota)<br=
 class=3D""><br class=3D"">Part of the soft lockup path actually =
specifies that it is going through __xfs_filemap_fault():<br =
class=3D""></blockquote><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">Right, I have just missed that.</span><br style=3D"caret-color:=
 rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">[...]</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D"">If I switch the backing file to a =
ext4 filesystem (separate hard drive), it OOMs.<br class=3D""><br =
class=3D""><br class=3D"">If I switch the file used to /dev/zero, it =
OOMs:<span class=3D"Apple-converted-space">&nbsp;</span><br =
class=3D"">=E2=80=A6<br class=3D"">Todal sum was 0. Loop count is 11<br =
class=3D"">Buffer is @ 0x7f2b66c00000<br =
class=3D"">./test-script-devzero.sh: line 16: &nbsp;3561 Killed =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;./leaker -p 10240 -c 100000<br class=3D""><br =
class=3D""><br class=3D""><blockquote type=3D"cite" class=3D"">Or could =
you try to<br class=3D"">simplify your test even further? E.g. does =
everything work as expected<br class=3D"">when doing anonymous mmap =
rather than file backed one?<br class=3D""></blockquote><br class=3D"">It =
also OOMs with MAP_ANON.<span =
class=3D"Apple-converted-space">&nbsp;</span><br class=3D""><br =
class=3D"">Hope that helps.<br class=3D""></blockquote><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">It helps to focus more on the =
xfs reclaim path. Just to be sure, is</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">there any difference if you use cgroup v2? I do not expect to =
be but</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">just to be =
sure there are no v1 artifacts.</span><br style=3D"caret-color: rgb(0, =
0, 0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""></div></blockquote><div><br =
class=3D""></div><div>I was unable to use cgroups2. I=E2=80=99ve created =
the new control group, but the attempt to move a running process into it =
fails with =E2=80=98Device or resource busy=E2=80=99.</div><div><br =
class=3D""></div><div>Masoud</div><br class=3D""><blockquote type=3D"cite"=
 class=3D""><div class=3D""><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">--<span class=3D"Apple-converted-space">&nbsp;</span></span><br=
 style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">Michal Hocko</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">SUSE =
Labs</span></div></blockquote></div><br class=3D""></body></html>=

--Apple-Mail=_182468D9-8FE1-460D-9C2F-1524ACE18F0F--

--Apple-Mail=_8FA53783-E4EB-4C34-821A-CE60ADDEE4C7
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

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
Y2E1ZzEuZGVyMDgGCCsGAQUFBzABhixodHRwOi8vb2NzcC5hcHBsZS5jb20vb2NzcDAzLWFwcGxl
aXN0Y2E1ZzEwMTAfBgNVHREEGDAWgRRtc2hhcmJpYW5pQGFwcGxlLmNvbTCCASoGA1UdIASCASEw
ggEdMIIBGQYLKoZIhvdjZAULBQEwggEIMIHKBggrBgEFBQcCAjCBvQyBulJlbGlhbmNlIG9uIHRo
aXMgY2VydGlmaWNhdGUgYXNzdW1lcyBhY2NlcHRhbmNlIG9mIGFueSBhcHBsaWNhYmxlIHRlcm1z
IG9mIHVzZSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRzLiBUaGlzIGNlcnRp
ZmljYXRlIHNoYWxsIG5vdCBzZXJ2ZSBhcywgb3IgcmVwbGFjZSBhIHdyaXR0ZW4gc2lnbmF0dXJl
LjA5BggrBgEFBQcCARYtaHR0cDovL3d3dy5hcHBsZS5jb20vY2VydGlmaWNhdGVhdXRob3JpdHkv
cnBhMBMGA1UdJQQMMAoGCCsGAQUFBwMEMDcGA1UdHwQwMC4wLKAqoCiGJmh0dHA6Ly9jcmwuYXBw
bGUuY29tL2FwcGxlaXN0Y2E1ZzEuY3JsMB0GA1UdDgQWBBR5OmXQsx80at576fQVWG/05OardjAO
BgNVHQ8BAf8EBAMCBaAwDQYJKoZIhvcNAQELBQADggEBAMavb8+8hvTGbqNfz0g9P4Alj5YKpTnW
pt1NNuyl9qR+QVooK8oMbGTB6cbSSKX7lcAW7motP5eRF0EiKXiu+IIgPhmDWKkbKnrrWK9AGhVn
xpm3OCnRHt2b+zYbkGGty0HYncIRdy3acTr+0T9Vs4xANJHwBIqUnkW5XKbPiZkv+EVKAsnL5CYD
npLI/uslfLquUYe6o8XIBVNYhmxEcxeCXbeESEk/KutdL+JcV4SpNoEB6Y4Dk1ZnHYOZRiLV3ZEG
neaCYYxam7SPWxeXqLtgeQMEEPgqj6pj430BQ/NKmCqdwRv2Sd0wXlKEDMul7jmWVUiRd6Nijgy5
7E2hn9MxggMgMIIDHAIBATB2MGIxHDAaBgNVBAMTE0FwcGxlIElTVCBDQSA1IC0gRzExIDAeBgNV
BAsTF0NlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKEwpBcHBsZSBJbmMuMQswCQYDVQQG
EwJVUwIQDNpHL/RwufOMyUmvGQQ2czANBglghkgBZQMEAgEFAKCCAXswGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkwODAyMjMyODI2WjAvBgkqhkiG9w0BCQQxIgQg
h3LATf8f0yaP4xwoxwXYArFDkmixF5xAUsibD15zvi8wgYUGCSsGAQQBgjcQBDF4MHYwYjEcMBoG
A1UEAxMTQXBwbGUgSVNUIENBIDUgLSBHMTEgMB4GA1UECxMXQ2VydGlmaWNhdGlvbiBBdXRob3Jp
dHkxEzARBgNVBAoTCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTAhAM2kcv9HC584zJSa8ZBDZzMIGH
BgsqhkiG9w0BCRACCzF4oHYwYjEcMBoGA1UEAxMTQXBwbGUgSVNUIENBIDUgLSBHMTEgMB4GA1UE
CxMXQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxEzARBgNVBAoTCkFwcGxlIEluYy4xCzAJBgNVBAYT
AlVTAhAM2kcv9HC584zJSa8ZBDZzMA0GCSqGSIb3DQEBAQUABIIBAJ3X/8n8+Tdlx9HZH2frQkjs
1cFI2L3G4NyYP6evoNaBRPNZ47dMBBKcgO0v5FPRLipHQdNP93BB9xIalRm0hY8go4YihRqS4RV2
4JlEVo4Fan4TvKF61LlLC0DwVoPvxYllOF4S0ClkdXOyE1PZlgJCFApJa9fuv1GPWzJlwZFbc+GT
CvHNgE651kp4rADV0Qqk1zOXmNpjMikUnQbRSRbk4c3U5qnwRLG2fkedjgF+cinUL720BWCBNMij
KPJx5+6dZBZFFRpAY9qT8qxoO7A38z0pj3Y2N4q/xoNTt0o7pbf9p2//fgSe5YUnIYADFhinOq9q
URX+ZXEaJinOyDcAAAAAAAA=
--Apple-Mail=_8FA53783-E4EB-4C34-821A-CE60ADDEE4C7--

