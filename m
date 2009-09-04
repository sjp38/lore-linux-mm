Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D8CF76B0085
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 18:28:54 -0400 (EDT)
Received: by fxm18 with SMTP id 18so972578fxm.38
        for <linux-mm@kvack.org>; Fri, 04 Sep 2009 15:29:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
References: <4A983C52.7000803@redhat.com>
	 <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
	 <4A9FB83F.2000605@redhat.com>
	 <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
Date: Fri, 4 Sep 2009 15:29:02 -0700
Message-ID: <7928e7bd0909041529i6d745955paa636206b9409587@mail.gmail.com>
Subject: Re: improving checksum cpu consumption in ksm
From: Moussa Ba <moussa.a.ba@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org, jaredeh@gmail.com
List-ID: <linux-mm.kvack.org>

Just to add to the discussion, we have also seen a high cpu usage for
KSM.  In our case however it is more serious as the system that KSM is
running on is battery powered  with a weaker processor.  With KSM
constantly running, the effect on the battery life is significant.

I like the idea of dirty bit tracking as it would obviate the need to
rehash once we know the page has not been dirtied.  We have been
working on a patch that adds dirty bit clearing from user space,
similar to the clear_refs entry under /proc/pid/.  In our instance we
use this mechanism to measure page accesses and write frequency on
ANONYMOUS pages, file backed pages or both.  Could this potentially
pose a problem if KSM decides to use that mechanism for page state
tracking?

Moussa.

On Thu, Sep 3, 2009 at 8:20 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk> wr=
ote:
> On Thu, 3 Sep 2009, Izik Eidus wrote:
>>
>> Hi,
>> I just did small test of the new hash compare to the old
>>
>> using the program below, i ran ksm (with nice -20)
>> at time_to_sleep_in_millisecs =3D 1
>
> Better 0?
>
>> run =3D 1
>> pages_to_scan =3D 9999
>
> Okay, the bigger the better.
>
>>
>> (The program is designing just to =A0pressure the hash calcs and tree wa=
lking
>> (and not to share any page really)
>>
>> then i checked how many full_scans have ksm reached (i just checked
>> /sys/kernel/mm/ksm/full_scans)
>>
>> And i got the following results:
>> with the old jhash version ksm did 395 loops
>> with the new jhash version ksm did 455 loops
>
> The first few loops will be settling down, need to subtract those.
>
>> we got here 15% improvment for this case where we have pages that are st=
atic
>> but are not shareable...
>> (And it will help in any case we got page we are not merging in the stab=
le
>> tree)
>>
>> I think it is nice...
>
> Yes, that's nice, thank you for looking into it.
>
> But please do some more along these lines, if you've time?
> Presumably the improvement from Jenkins lookup2 to lookup3
> is therefore more than 15%, but we cannot tell how much.
>
> I think you need to do a run with a null version of jhash2(),
> one just returning 0 or 0xffffffff (the first would settle down
> a little quicker because oldchecksum 0 will match the first time;
> but there should be no difference once you cut out settling time).
>
> And a run with an almost-null version of jhash2(), one which does
> also read the whole page sequentially into cache, so we can see
> how much is the processing and how much is the memory access.
>
> And also, while you're about it, a run with cmp_and_merge_page()
> stubbed out, so we can see how much is just the page table walking
> (and deduce from that how much is the radix tree walking and memcmping).
>
> Hmm, and a run to see how much is radix tree walking,
> by stubbing out the memcmping.
>
> Sorry... if you (or someone else following) have the time!
>
>>
>> (I used =A0AMD Phenom(tm) II X3 720 Processor, but probably i didnt run =
the test
>> enougth, i should rerun it again and see if the results are consistent)
>
> Right, other processors will differ some(unknown)what, so we shouldn't
> take the numbers you find too seriously. =A0But at this moment I've no
> idea of what proportion of time is spent on what: it should be helpful
> to see what dominates.
>
>>
>> =A0 =A0p =3D (unsigned char *) malloc(1024 * 1024 * 100 + 4096);
>> =A0 =A0if (!p) {
>> =A0 =A0 =A0 =A0printf("error\n");
>> =A0 =A0}
>>
>> =A0 =A0p_end =3D p + 1024 * 1024 * 100;
>> =A0 =A0p =3D (unsigned char *)((unsigned long)p & ~4095);
>
> Doesn't matter to your results, so long as it didn't crash;
> but I think you meant to say
>
> =A0 =A0 p =3D (unsigned char *)(((unsigned long)p + 4095) & ~4095);
> =A0 =A0 p_end =3D p + 1024 * 1024 * 100;
>
> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
