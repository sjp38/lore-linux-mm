Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id AE4C56B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:27:45 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id x54so1312935wes.18
        for <linux-mm@kvack.org>; Fri, 30 Aug 2013 01:27:44 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <52205597.3090609@synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
	<1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	<CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
	<1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
	<521DE5D7.4040305@synopsys.com>
	<CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
	<CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
	<52205597.3090609@synopsys.com>
Date: Fri, 30 Aug 2013 10:27:43 +0200
Message-ID: <CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
Subject: Re: ipc-msg broken again on 3.11-rc7? (was Re: linux-next: Tree for
 Jun 21 [ BROKEN ipc/ipc-msg ])
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: multipart/mixed; boundary=047d7b624e7e25cfdf04e525ff1f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineetg76@gmail.com>
Cc: linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

--047d7b624e7e25cfdf04e525ff1f
Content-Type: text/plain; charset=UTF-8

On Fri, Aug 30, 2013 at 10:19 AM, Vineet Gupta <vineetg76@gmail.com> wrote:
> Ping ?
>
> It seems 3.11 is pretty close to releasing but we stil have LTP msgctl08 causing a
> hang (atleast on ARC) for both linux-next 20130829 as well as Linus tree.
>
> So far, I haven't seemed to have drawn attention of people involved.
>

Hi Vineet,

I remember fakeroot was an another good test-case for me to test this
IPC breakage.
Attached is my build-script for Linux-next (tested with Debian/Ubuntu).
( Cannot say if you can play with it in your environment. )

Regards,
- Sedat -

> -Vineet
>
> On 08/29/2013 01:22 PM, Sedat Dilek wrote:
>> On Thu, Aug 29, 2013 at 9:21 AM, Vineet Gupta
>> <Vineet.Gupta1@synopsys.com> wrote:
>>> On 08/29/2013 08:34 AM, Sedat Dilek wrote:
>>>> On Wed, Aug 28, 2013 at 1:58 PM, Vineet Gupta
>>>> <Vineet.Gupta1@synopsys.com> wrote:
>>>>> Hi David,
>>>>>
>
> [....]
>
>>>>> LTP msgctl08 hangs on 3.11-rc7 (ARC port) with some of my local changes. I
>>>>> bisected it, sigh... didn't look at this thread earlier :-( and landed into this.
>>>>>
>>>>> ------------->8------------------------------------
>>>>> 3dd1f784ed6603d7ab1043e51e6371235edf2313 is the first bad commit
>>>>> commit 3dd1f784ed6603d7ab1043e51e6371235edf2313
>>>>> Author: Davidlohr Bueso <davidlohr.bueso@hp.com>
>>>>> Date:   Mon Jul 8 16:01:17 2013 -0700
>>>>>
>>>>>     ipc,msg: shorten critical region in msgsnd
>>>>>
>>>>>     do_msgsnd() is another function that does too many things with the ipc
>>>>>     object lock acquired.  Take it only when needed when actually updating
>>>>>     msq.
>>>>> ------------->8------------------------------------
>>>>>
>>>>> If I revert 3dd1f784ed66 and 9ad66ae "ipc: remove unused functions" - the test
>>>>> passes. I can confirm that linux-next also has the issue (didn't try the revert
>>>>> there though).
>>>>>
>>>>> 1. arc 3.11-rc7 config attached (UP + PREEMPT)
>>>>> 2. dmesg prints "msgmni has been set to 479"
>>>>> 3. LTP output (this is slightly dated source, so prints might vary)
>>>>>
>>>>> ------------->8------------------------------------
>>>>> <<<test_start>>>
>>>>> tag=msgctl08 stime=1377689180
>>>>> cmdline="msgctl08"
>>>>> contacts=""
>>>>> analysis=exit
>>>>> initiation_status="ok"
>>>>> <<<test_output>>>
>>>>> ------------->8-------- hung here ------------------
>>>>>
>>>>>
>>>>> Let me know if you need more data/test help.
>>>>>
>>>> Cannot say much to your constellation as I had the issue on x86-64 and
>>>> Linux-next.
>>>> But I have just seen a post-v3.11-rc7 IPC-fix in [1].
>>>>
>>>> I have here a v3.11-rc7 kernel with drm-intel-nightly on top... did not run LTP.
>>>
>>> Not sure what you mean - I'd posted that Im seeing the issue on ARC Linux (an FPGA
>>> board) 3.11-rc7 as well as linux-next of yesterday.
>>>
>>
>> I am not saying there is no issue, but I have no possibility to test
>> for ARC arch.
>>
>>>> Which LTP release do you use?
>>>
>>> The LTP build I generally use is from a 2007 based sources (lazy me). However I
>>> knew this would come up so before posting, I'd built the latest from buildroot and
>>> ran the msgctl08 from there standalone and it did the same thing.
>>>
>>
>> Try always latest LTP-stable (03-May-2013 is what I tried). AFAICS a
>> new release is planned soon.
>>
>>>> Might be good to attach your kernel-config for followers?
>>>
>>> It was already there in my orig msg - you probably missed it.
>>>
>>
>> I have got that response from you only :-).
>>
>>>> [1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=368ae537e056acd3f751fa276f48423f06803922
>>>
>>> I tried linux-next of today, same deal - msgctl08 still hangs.
>>>
>>
>> That above fix [1] in Linus-tree is also in next-20130828.
>>
>> Hope Davidlohr and fellows can help you.
>>
>> - Sedat -
>>
>

--047d7b624e7e25cfdf04e525ff1f
Content-Type: application/x-sh; name="build_linux-next.sh"
Content-Disposition: attachment; filename="build_linux-next.sh"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hkz51iqx0

IyEvYmluL3NoCgojIyMgSEVMUAojIDEuIG1ha2UgZGViLXBrZyAob3B0aW9ucyk6ICA8ZmlsZTog
c2NyaXB0cy9wYWNrYWdlL2J1aWxkZGViPgojIDIuIGxvY2FsdmVyc2lvbiBoYW5kbGluZzogICA8
ZmlsZTogc2NyaXB0cy9zZXRsb2NhbHZlcnNpb24+CiMgMy4gS0JVSUxEX1VTRVJfKiB2YXJpYWJs
ZXM6IDxmaWxlOiBzY3JpcHRzL21rY29tcGlsZV9oPgojIDQuIFByZXJlcXMvUHJlcGFyYXRpb246
ICAgICA8aHR0cDovL2tlcm5lbC1oYW5kYm9vay5hbGlvdGguZGViaWFuLm9yZy9jaC1jb21tb24t
dGFza3MuaHRtbCNzNC4yLjE+CgojIyMgUFJFUkVRUzogSW5zdGFsbCBidWlsZC1lc3NlbnRpYWws
IGZha2Vyb290IGFuZCBkcGtnLWRldiBwYWNrYWdlcyAob3B0aW9uYWw6IGdpdCkhCiNhcHQtZ2V0
IHVwZGF0ZQojYXB0LWdldCBpbnN0YWxsIGJ1aWxkLWVzc2VudGlhbCBmYWtlcm9vdCBkcGtnLWRl
dgojYXB0LWdldCBpbnN0YWxsIGdpdAoKIyMjIExhbmd1YWdlIHNldHRpbmdzCmV4cG9ydCBMQU5H
PUMKZXhwb3J0IExDX0FMTD1DCgojIyMgQmFzZSBpcyBMaW51eC1uZXh0IHNvdXJjZSBkaXJlY3Rv
cnkKQkFTRV9ESVI9JChwd2QpClNSQ19ESVI9IiR7QkFTRV9ESVJ9L2xpbnV4LW5leHQiCgojIyMg
Q2xvbmUgTGludXgtbmV4dCByZW1vdGUgR0lUIHRyZWUKI0dJVF9VUkw9ImdpdDovL2dpdC5rZXJu
ZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9uZXh0L2xpbnV4LW5leHQuZ2l0IgojZ2l0
IGNsb25lICR7R0lUX1VSTH0KCiMjIyBDaGFuZ2UgdG8gYnVpbGQgZGlyZWN0b3J5CmNkICR7U1JD
X0RJUn0KCiMjIyBNYWtlIGFuZCBjb21waWxlciBzZXR0aW5ncwpNQUtFPSJtYWtlIgpNQUtFX0pP
QlM9JChnZXRjb25mIF9OUFJPQ0VTU09SU19PTkxOKQpDQ19GT1JfQlVJTEQ9ImdjYy00LjYiCgoj
IyMgVXBsb2FkZXI6IHJlYWxuYW1lL25pY2tuYW1lIGFuZCBlbWFpbCBzZXR0aW5ncwpleHBvcnQg
REVCRlVMTE5BTUU9IlNlZGF0IERpbGVrIgpleHBvcnQgREVCRU1BSUw9InNlZGF0LmRpbGVrQGdt
YWlsLmNvbSIKdXBsb2FkZXI9ImRpbGVrcyIKCiMjIyBFeHRyYWN0IHZlcnNpb24gc2V0dGluZ3Mg
ZnJvbSBNYWtlZmlsZQp2ZXJzaW9uPSQoYXdrICcvXlZFUlNJT04gPSAvIHtwcmludCAkM30nIE1h
a2VmaWxlKQpwYXRjaGxldmVsPSQoYXdrICcvXlBBVENITEVWRUwgPSAvIHtwcmludCAkM30nIE1h
a2VmaWxlKQpzdWJsZXZlbD0kKGF3ayAnL15TVUJMRVZFTCA9IC8ge3ByaW50ICQzfScgTWFrZWZp
bGUpCmV4dHJhdmVyc2lvbj0kKGF3ayAnL15FWFRSQVZFUlNJT04gPSAvIHtwcmludCAkM30nIE1h
a2VmaWxlKQp1cHN0cmVhbV92ZXJzaW9uPSIke3ZlcnNpb259LiR7cGF0Y2hsZXZlbH0uJHtzdWJs
ZXZlbH0ke2V4dHJhdmVyc2lvbn0iCgojIyMgRXh0cmFjdCB2ZXJzaW9uLXRhZ3MgZnJvbSBsb2Nh
bCBHSVQgdHJlZQpMQVRFU1RfVVBTVFJFQU1fVkVSX1RBRz0kKGdpdCBmb3ItZWFjaC1yZWYgLS1z
b3J0PXRhZ2dlcmRhdGUgLS1mb3JtYXQ9IiUocmVmbmFtZTpzaG9ydCkiIHJlZnMvdGFncyB8IGdy
ZXAgXid2WzAtOV0uWzAtOV0qJyB8IHRhaWwgLTEpCkxBVEVTVF9ORVhUX1ZFUl9UQUc9JChnaXQg
Zm9yLWVhY2gtcmVmIC0tc29ydD10YWdnZXJkYXRlIC0tZm9ybWF0PSIlKHJlZm5hbWU6c2hvcnQp
IiByZWZzL3RhZ3MgfCBncmVwIF4nbmV4dC1bMC05XVx7OFx9JyB8IHRhaWwgLTEpCgojIyMgRGVi
aWFuLXJldmlzaW9uIHNldHRpbmdzCiMgTk9URS0xOiAkcmV2aXNpb24gd2lsbCBiZSBhcHBlbmRl
ZCB0byAkZGViaWFuX3JldmlzaW9uIGFuZCAkbXlsb2NhbHZlcnNpb24KIyBOT1RFLTI6IExpbnV4
LXVwc3RyZWFtOiAkcmV2aXNpb24gc3RhcnRzIGF0ICIxIiB3aXRoIGVhY2ggbmV3IHYzLngueSAo
bmV4dDogeSsxKSBvciB2My54LjAtcmNYIChuZXh0OiBYKzEpCiMgTk9URS0zOiBMaW51eC1uZXh0
OiAkcmV2aXNpb24gc3RhcnRzIGF0ICIxIiB3aXRoIGVhY2ggbGludXgtbmV4dCByZWxlYXNlCiMg
RVhBTVBMRTogZGViaWFuX3JldmlzaW9uPSIxK2RpbGVrczEiCnJldmlzaW9uPSIxIgp1cGxvYWRl
cl9yZXZpc2lvbj0iMSIKZGViaWFuX3JldmlzaW9uPSIke3JldmlzaW9ufSske3VwbG9hZGVyfSR7
dXBsb2FkZXJfcmV2aXNpb259IgoKIyMjIEV4dHJhY3QgJG15bG9jYWx2ZXJzaW9uX25leHQKIyBO
T1RFOiAkbXlsb2NhbHZlcnNpb25fbmV4dCB3aWxsIGJlIGFwcGVuZGVkIHRvICRteWxvY2FsdmVy
c2lvbgojIEVYQU1QTEU6IG15bG9jYWx2ZXJzaW9uX25leHQ9Im5leHQyMDEzMDEyNSIKbXlsb2Nh
bHZlcnNpb25fbmV4dD0kKGVjaG8gJExBVEVTVF9ORVhUX1ZFUl9UQUcgfCB0ciAtZCAnLScpCgoj
IyMgTXkgZmVhdHVyZXNldCBzZXR0aW5ncwojIEhlcmU6IFVzZSBvd24gImluaXphIiBmZWF0dXJl
c2V0Cm15ZmVhdHVyZXNldD0iaW5pemEiCgojIyMgTXkga2VybmVsLWZsYXZvdXIgc2V0dGluZ3MK
IyBIZXJlOiBVc2Ugb3duICJzbWFsbCIga2VybmVsLWZsYXZvdXIgKGxvY2FsbW9kY29uZmlnLWVk
IHBsdXMgc29tZSBkZWJ1Zy1vcHRpb25zIGVuYWJsZWQpIApteWtlcm5lbGZsYXZvdXI9InNtYWxs
IgoKIyMjIEN1c3RvbWl6ZWQgTE9DQUxWRVJTSU9OIHNldHRpbmdzCiMgTk9URS0xOiAkbXlsb2Nh
bHZlcnNpb24gaXMgYXR0YWNoZWQgYXMgc3VmZml4IHRvICJpbmNsdWRlL2dlbmVyYXRlZC91dHNy
ZWxlYXNlLmgiIGZpbGUKIyBOT1RFLTI6IFVzYWdlIG9mIExPQ0FMVkVSU0lPTj0kbXlsb2NhbHZl
cnNpb24gc3VwcHJlc3NlcyAiKyIgc3VmZml4CiMgTk9URS0zOiBTZWUgYWxzbyAiI2RlZmluZSBV
VFNfUkVMRUFTRSIgaW4gdXRzcmVsZWFzZS5oIGZpbGUuCiMgV0FSTklORzogRG8gTk9UIHVzZSB1
bmRlcnNjb3JlICgiXyIpIGluICRteWxvY2FsdmVyc2lvbiAoc2VlIDxodHRwOi8vYnVncy5kZWJp
YW4ub3JnLzIyMjQ2Nz4pLgojIEVYQU1QTEUtMTogIm5leHQyMDEzMDEyNSIgKG15bG9jYWx2ZXJz
aW9uX25leHQpICsgIjEiIChyZXZpc2lvbikgKyAiaW5pemEiIChteWZlYXR1cmVzZXQpICsgInNt
YWxsIiAobXlrZXJuZWxmbGF2b3VyKQojIEVYQU1QTEUtMjogbXlsb2NhbHZlcnNpb249Ii1uZXh0
MjAxMzAxMjUtMS1pbml6YS1zbWFsbCIKIyBFWEFNUExFLTM6IG15bG9jYWx2ZXJzaW9uPSItbmV4
dDIwMTMwMTI1LTEtaW5pemEteDg2XzY0IiAoZHBrZy1nZW5jb250cm9sOiBlcnJvcjogSWxsZWdh
bCBwYWNrYWdlIG5hbWUgLi4uKQpteWxvY2FsdmVyc2lvbj0iLSR7bXlsb2NhbHZlcnNpb25fbmV4
dH0tJHtyZXZpc2lvbn0tJHtteWZlYXR1cmVzZXR9LSR7bXlrZXJuZWxmbGF2b3VyfSIKCiMjIyBN
eSBrZXJuZWwtcmVsZWFzZSAoYWthIEtWRVIpCm15a2VybmVscmVsZWFzZT0iJHt1cHN0cmVhbV92
ZXJzaW9ufSR7bXlsb2NhbHZlcnNpb259IgoKIyMjIEJ1aWxkLWxvZyBmaWxlCkJVSUxEX0xPR19G
SUxFPSJidWlsZC1sb2dfJHtteWtlcm5lbHJlbGVhc2V9LnR4dCIKCiMjIyBtYWtlIG9wdGlvbnMK
TUFLRV9PUFRTPSJDQz0ke0NDX0ZPUl9CVUlMRH0gLWoke01BS0VfSk9CU30gS0JVSUxEX0JVSUxE
X1VTRVI9JHtERUJFTUFJTH0gTE9DQUxWRVJTSU9OPSR7bXlsb2NhbHZlcnNpb259IgoKIyMjIGRl
Yi1wa2cgb3B0aW9ucwojIE5PVEUtMTogQ2hhbmdlICctcmNYJyBpbiAkdXBzdHJlYW1fdmVyc2lv
biB0byAnfnJjWCcgY2F1c2VkIGJ5ICRleHRyYXZlcnNpb24KIyBOT1RFLTI6IEFkZCAkbXlmZWF0
dXJlc2V0IHRvICRkZWJpYW5fcmV2aXNpb24KIyBFWEFNUExFLTE6ICIzLjguMC1yYzQiIC0+ICIz
LjguMH5yYzQiCiMgRVhBTVBMRS0yOiBLREVCX1BLR1ZFUlNJT049IjMuOC4wfnJjNH5uZXh0MjAx
MzAxMjUtMX5pbml6YStkaWxla3MxIgp1cHN0cmVhbV92ZXJzaW9uPSQoZWNobyAkdXBzdHJlYW1f
dmVyc2lvbiB8IHRyICctJyAnficpCmRlYmlhbl9yZXZpc2lvbj0iJHtyZXZpc2lvbn1+JHtteWZl
YXR1cmVzZXR9KyR7dXBsb2FkZXJ9JHt1cGxvYWRlcl9yZXZpc2lvbn0iCkRFQl9QS0dfT1BUUz0i
S0RFQl9QS0dWRVJTSU9OPSR7dXBzdHJlYW1fdmVyc2lvbn1+JHtteWxvY2FsdmVyc2lvbl9uZXh0
fS0ke2RlYmlhbl9yZXZpc2lvbn0iCgplY2hvICJMaW51eC11cHN0cmVhbSB2ZXJzaW9uIC4uLiAk
e0xBVEVTVF9VUFNUUkVBTV9WRVJfVEFHfSIKZWNobyAiTGludXgtbmV4dCB2ZXJzaW9uIC4uLi4u
Li4gJHtMQVRFU1RfTkVYVF9WRVJfVEFHfSIKZWNobyAibWFrZSBvcHRpb25zIC4uLi4uLi4uLi4u
Li4gJHtNQUtFX09QVFN9IgplY2hvICJkZXAtcGtnIG9wdGlvbnMgLi4uLi4uLi4uLiAke0RFQl9Q
S0dfT1BUU30iCmVjaG8gIiIKCiMjIyBSZW1vdmUgYW55IGV4aXN0aW5nIGxvY2FsdmVyc2lvbiog
ZmlsZShzKSBhcyBteSBjdXN0b21pemVkIExPQ0FMVkVSU0lPTiBpcyB1c2VkCiMgTk9URTogTGlu
dXgtbmV4dCBzaGlwcyBhICJsb2NhbHZlcnNpb24tbmV4dCIgZmlsZS4Kcm0gLWYgbG9jYWx2ZXJz
aW9uKgoKIyMjIFN0YXJ0IGJ1aWxkCmVjaG8gIiMjIyMjIFN0YXJ0aW5nIExpbnV4LWtlcm5lbCBi
dWlsZCAuLi4iCmZha2Vyb290ICR7TUFLRX0gJHtNQUtFX09QVFN9IGRlYi1wa2cgJHtERUJfUEtH
X09QVFN9IDI+JjEgfCB0ZWUgLi4vJHtCVUlMRF9MT0dfRklMRX0KZWNobyAiIyMjIyMgRmluaXNo
ZWQhIgo=
--047d7b624e7e25cfdf04e525ff1f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
