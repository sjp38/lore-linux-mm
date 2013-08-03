Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 969546B0031
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 19:54:59 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id j6so3930024oag.28
        for <linux-mm@kvack.org>; Sat, 03 Aug 2013 16:54:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130801083608.GJ221@brightrain.aerifal.cx>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
 <20130622103158.GA16304@infradead.org> <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
 <20130801082951.GA23563@infradead.org> <20130801083608.GJ221@brightrain.aerifal.cx>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 3 Aug 2013 19:54:38 -0400
Message-ID: <CAHGf_=pY=ap-T3R0bK4675THvGikzH1KpMbEz3==_EwPBkebRQ@mail.gmail.com>
Subject: Re: RFC: named anonymous vmas
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rich Felker <dalias@aerifal.cx>
Cc: Christoph Hellwig <hch@infradead.org>, Colin Cross <ccross@google.com>, lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>, libc-alpha <libc-alpha@sourceware.org>

On Thu, Aug 1, 2013 at 4:36 AM, Rich Felker <dalias@aerifal.cx> wrote:
> On Thu, Aug 01, 2013 at 01:29:51AM -0700, Christoph Hellwig wrote:
>> Btw, FreeBSD has an extension to shm_open to create unnamed but fd
>> passable segments.  From their man page:
>>
>>     As a FreeBSD extension, the constant SHM_ANON may be used for the path
>>     argument to shm_open().  In this case, an anonymous, unnamed shared
>>     memory object is created.  Since the object has no name, it cannot be
>>     removed via a subsequent call to shm_unlink().  Instead, the shared
>>     memory object will be garbage collected when the last reference to the
>>     shared memory object is removed.  The shared memory object may be shared
>>     with other processes by sharing the file descriptor via fork(2) or
>>     sendmsg(2).  Attempting to open an anonymous shared memory object with
>>     O_RDONLY will fail with EINVAL. All other flags are ignored.
>>
>> To me this sounds like the best way to expose this functionality to the
>> user.  Implementing it is another question as shm_open sits in libc,
>> we could either take it and shm_unlink to the kernel, or use O_TMPFILE
>> on tmpfs as the backend.
>
> I'm not sure what the purpose is. shm_open with a long random filename
> and O_EXCL|O_CREAT, followed immediately by shm_unlink, is just as
> good except in the case where you have a malicious user killing the
> process in between these two operations.

Practically, filename length is restricted by NAME_MAX(255bytes). Several
people don't think it is enough long length. The point is, race free API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
