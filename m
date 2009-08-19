Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F7176B005A
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 05:08:26 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1662734ana.26
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 02:07:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090818083024.GB31469@csn.ul.ie>
References: <alpine.LFD.2.00.0908172346460.32114@casper.infradead.org>
	 <20090818083024.GB31469@csn.ul.ie>
Date: Wed, 19 Aug 2009 21:01:17 +1200
Message-ID: <202cde0e0908190201p4c2e2701xf18bdecbc53df905@mail.gmail.com>
Subject: Re: HTLB mapping for drivers. Driver example
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel,


>
> This seems a lot of burden to put on a device driver, particularly with
> respect to the reservations.

Thanks a lot for review you did. That is right.  I don't like this
burden as well.
>
>> File operations of /dev/hpage_map do the following:
>>
>> In file open we =C2=A0associate mappings of /dev/xxx with the file on hu=
getlbfs (like it is done in ipc/shm.c)
>> =C2=A0 =C2=A0 =C2=A0 file->f_mapping =3D h_file->f_mapping;
>>
>> In get_unmapped_area we should tell about addressing constraints in case=
 of huge pages by calling hugetlbfs procedures. (as in ipc/shm.c)
>> =C2=A0 =C2=A0 =C2=A0 return get_unmapped_area(h_file, addr, len, pgoff, =
flags);
>>
>> We need to let hugetlbfs do architecture specific operations with mappin=
g in mmap call. This driver does not reserve any memory for private mapping=
s
>> so driver requests reservation from hugetlbfs. (Actually driver can do t=
his as well but it will make it more complex)
>>
>> The exit procedure:
>> * removes memory from page cache
>> * deletes file on hugetlbfs vfs mount
>> * =C2=A0free pages
>>
>> Application example is not shown here but it is very simple. It does the=
 following: open file /dev/hpage_map, mmap a region, read/write memory, unm=
ap file, close file.
>>
>
> For the use-model you have in mind, could you look at Eric Munson's patch=
es
> and determine if the target application would have been happy to call the
> following please?
>
> mmap(0, len, prot, MAP_ANONYMOUS|MAP_HUGETLB, 0, 0)
>
Hmm. But how can I at least identify which driver this call is addressed to=
?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
